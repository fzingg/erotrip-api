class WantToMeetButton < Hyperloop::Component

	param :user

	state accepted: false

  # Warning: setState(...): Can only update a mounted or mounting component. This usually means you called setState() on an unmounted component. This is a no-op. Please check the code for the UserButton component.
  # before_unmount do
  #   mutate.button_animated(true)
  # end

	def render
		# #{'wants-to-meet-me' if does_want_to_meet_me?}
    button(class: "btn icon-only btn-want-to-meet btn-no-focus #{'we-are-matched' if (we_are_matched || state.accepted)} #{'i-want-to-meet' if do_i_want_to_meet? && !we_are_matched && state.accepted != true}", type: "button") do
      i(class: 'ero-heart f-s-25 mt-1')
    end.on :click do
      take_proper_action
    end
  end

  def take_proper_action
    if CurrentUserStore.current_user_id.blank?
      ModalsService.open_modal('RegistrationModal', { callback: proc { process_wtm } })
    else
  		process_wtm
    end

  end

  def process_wtm
    if CurrentUserStore.current_user_id
      GetWantToMeetStatus.run(user_id: params.user.try(:id)).then do |status|
        if status
          if status == "no_relation"
            create_want_to_meet
          elsif status == "he_wants_to_meet_and_not_accepted"
            accept_want_to_meet
          elsif status == "i_want_to_meet"
            puts "już lubisz te osobę!"
          end
        else
          puts "Oops, coś poszło nie tak"
        end
      end
    end

	end

	def we_are_matched
    if CurrentUserStore.current_user && CurrentUserStore.current_user_id && params.user.try(:id)
      if want_to_meet = (WantToMeet.where_user_and_want_to_meet(CurrentUserStore.current_user_id, params.user.try(:id)).where_accepted_by_want_to_meet(true).first) || (WantToMeet.where_user_and_want_to_meet(params.user.try(:id), CurrentUserStore.current_user_id).where_accepted_by_want_to_meet(true).first)
        if want_to_meet.present? && want_to_meet.id.present? && want_to_meet.id.loaded?
          true
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

	def create_want_to_meet
		SaveWantToMeet.run(user_id: CurrentUserStore.current_user_id, want_to_meet_id: params.user.try(:id) )
    .fail do |error|
			`toast.error("Nie udało się dodać.")`
		end
	end

	def accept_want_to_meet
		AcceptWantToMeet.run(user_id: params.user.try(:id)).then do |response|
			mutate.accepted true
			GetRoomUserForContextAndJoin.run({ context_type: 'User', context_id: params.user.try(:id), user_id: params.user.try(:id) })
			.then do |room_user|
				ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static', initial_room_user_id: room_user.try(:id), is_paired: true})
			end.catch do |e|
				`toast.error('Nie udało się otworzyć czatu...')`
			end
		end.fail do |error|
			`toast.error("Ooops! Coś poszło nie tak.")`
		end
	end

  def does_want_to_meet_me?
    CurrentUserStore.current_user_id ? (CurrentUserStore.current_user.try(:wanted_to_been_met_by_users) || []).include?(params.user) : false
  end

	def do_i_want_to_meet?
    CurrentUserStore.current_user_id ? (params.user.try(:wanted_to_been_met_by_users) || []).include?(CurrentUserStore.current_user) : false
  end
end