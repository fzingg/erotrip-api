class SaveWantToMeet < Hyperloop::ControllerOp; end
class SaveWantToMeet < Hyperloop::ControllerOp
  param user_id: nil, nils: false #pass this param, but its not used
  param want_to_meet_id: nil, nils: false

	step do
		if acting_user && acting_user.id == params.user_id
			reverse_wtm = WantToMeet.where(want_to_meet_id: params.user_id).where(user_id: params.want_to_meet_id).first
			if !reverse_wtm
				wtm = WantToMeet.where(user_id: params.user_id, want_to_meet_id: params.want_to_meet_id).first_or_initialize do |w|
					w.user_id = params.user_id
					w.want_to_meet_id = params.want_to_meet_id
				end

				wtm.save

        Notify.run(to_who: wtm.want_to_meet, kind: 'user_wants_to_meet_you', additional_data: { other_user: wtm.user })
				if wtm.want_to_meet.is_active
					if wtm.want_to_meet.notification_settings["on_like"]["browser"]
						# PITER_NOTIFY_BROWSER
						# poinformowac wtm.want_to_meet o tym ze ktos chce go poznac
            Notify.run(to_who: wtm.want_to_meet, kind: 'user_wants_to_meet_you', additional_data: { other_user: wtm.user })
					end
				else
					if wtm.want_to_meet.notification_settings["on_like"]["email"]
						WantToMeetMailer.user_wants_to_meet_you(wtm.want_to_meet, wtm.user).deliver_later
						true
					end
				end
			else
				reverse_wtm.accepted_by_want_to_meet = true
				reverse_wtm.save
			end
		else
			false
		end
  end

  # step do |response|
  #   unless response[:success]
  #     raise ArgumentError, response[:saved_models]
  #   end
  #   return response
	# end
end unless RUBY_ENGINE == 'opal'