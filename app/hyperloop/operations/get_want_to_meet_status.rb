class GetWantToMeetStatus < Hyperloop::ControllerOp; end
class GetWantToMeetStatus < Hyperloop::ControllerOp
	param :user_id, nils: false

	def acceptation wtm
		if wtm.accepted_by_want_to_meet
			"accepted"
		else
			"not_accepted"
		end
	end

	step do
		if acting_user
			wtm = WantToMeet.where("(user_id = :acting_user_id AND want_to_meet_id = :user_id) OR (user_id = :user_id AND want_to_meet_id = :acting_user_id)", { acting_user_id: acting_user.id, user_id: params.user_id }).first

			if wtm.blank?
				"no_relation"
			else
				if wtm.user_id == acting_user.id
					"i_want_to_meet"
				else
					"he_wants_to_meet_and_#{acceptation(wtm)}"
				end
			end
		else
			false
		end
	end

	step do |response|
		response
	end
end unless RUBY_ENGINE == 'opal'