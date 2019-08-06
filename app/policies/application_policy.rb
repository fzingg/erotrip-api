class ApplicationPolicy
	always_allow_connection
	# Anyone can connect to Application channel - broadcasts will be seen by every browser session

	# regulate_all_broadcasts do |policy|
	# 	dont_send_to_admins = policy.obj.class.try(:dont_send_to_admins)
	# 	dont_send_to_users = policy.obj.class.try(:dont_send_to_users)
	# 	dont_send_to_guests = policy.obj.class.try(:dont_send_to_guests)

	# 	!!dont_send_to_admins ? policy.send_all_but(dont_send_to_admins).to(Admin) : policy.send_all.to(Admin)
	# 	!!dont_send_to_users ? policy.send_all_but(dont_send_to_users).to(User) : policy.send_all.to(User)
	# 	!!dont_send_to_guests ? policy.send_all_but(dont_send_to_guests).to(Application) : policy.send_all.to(Application)
	# end


	# always_dispatch_from(ProcessLogout)
	# always_dispatch_from(ProcessLogin)
end