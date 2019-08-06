class RemoveWantToMeet < Hyperloop::ControllerOp; end
class RemoveWantToMeet < Hyperloop::ControllerOp
  param user_id: nil, nils: false

	step do
		if acting_user
			# WantToMeet.where(user_id: acting_user.id, want_to_meet_id: params.user_id).first
			WantToMeet.where(user_id: params.user_id, want_to_meet_id: acting_user.id).first
		else
			raise Hyperloop::AccessViolation
		end
  end

  step do |want_to_meet|
		if want_to_meet
			want_to_meet.destroy
		else
			raise Hyperloop::AccessViolation
		end
	end

	failed do |error|
		"Operacja się nie powiodła"
	end
end unless RUBY_ENGINE == 'opal'
