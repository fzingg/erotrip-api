class AccessPermissionPolicy
	allow_create { acting_user }
	allow_update { acting_user && acting_user.is_admin? || acting_user.id == owner_id }
	allow_destroy { acting_user && acting_user.is_admin? || acting_user.id == owner_id }

	regulate_broadcast do |policy|
		policy.send_all.to(::Application)
	end
end