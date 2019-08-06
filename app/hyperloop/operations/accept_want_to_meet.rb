class AcceptWantToMeet < Hyperloop::ControllerOp; end
class AcceptWantToMeet < Hyperloop::ControllerOp
  param user_id: nil, nils: false # user_id of person who wants to meet acting user

	step do
		if acting_user
			WantToMeet.where(user_id: params.user_id, want_to_meet_id: acting_user.id).first
		else
			raise Hyperloop::AccessViolation
		end
  end

  step do |want_to_meet|
		if want_to_meet && want_to_meet.accepted_by_want_to_meet == false
			want_to_meet.accepted_by_want_to_meet = true
			want_to_meet.save

			if acting_user.notification_settings["on_fit"]["browser"]
				# PITER_NOTIFY_BROWSER
				# tutaj poinformowac aktualnie zalogowanego usera o tym ze go dopasowalo
				# PO CO? shoro sam kliknął, to wie
			end

			Notify.run({to_who: want_to_meet.user, kind: 'you_have_been_matched', additional_data: { other_user: want_to_meet.want_to_meet }})
			if want_to_meet.user.is_active
				if want_to_meet.user.notification_settings["on_fit"]["browser"]
					# PITER_NOTIFY_BROWSER
					# tutaj poinformowac want_to_meet.user o tym ze z kims go dopasowało
					Notify.run({to_who: want_to_meet.user, kind: 'you_have_been_matched', additional_data: { other_user: want_to_meet.want_to_meet }})
				end
			else
				if want_to_meet.user.notification_settings["on_fit"]["email"]
					WantToMeetMailer.you_have_been_matched(want_to_meet.user, want_to_meet.want_to_meet).deliver_later
				end
			end
		else
			true
		end
	end

	failed do |error|
		"Operacja się nie powiodła, #{error.inspect}"
	end
end unless RUBY_ENGINE == 'opal'
