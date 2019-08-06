class UserInterestPolicy
	allow_create { acting_user && acting_user.id == self.user_id }
	allow_update { acting_user && acting_user.id == self.user_id }
	allow_destroy { acting_user && acting_user.id == self.user_id }

	regulate_broadcast do |policy|
		policy.send_all.to(::Application)
	end
end