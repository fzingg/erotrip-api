class AlertPolicy

	allow_create { acting_user }
	allow_update { acting_user.try(:is_admin) }
	allow_destroy { acting_user.try(:is_admin) }

	regulate_broadcast do |policy|
		# policy.send_all.to(User.admins) if User.admins.any?
		policy.send_all.to(::Admin)
	end
end