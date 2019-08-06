class UserGroupPolicy
	allow_update { true }
	allow_create { true }
	allow_destroy { true }

	regulate_broadcast do |policy|
		# policy.send_all_but(:user, :user_id).to(::Application) if !is_public?
		policy.send_all.to(::Application)
	end
end