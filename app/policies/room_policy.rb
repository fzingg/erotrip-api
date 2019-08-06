class RoomPolicy
  # always_allow_connect # regulate_class_connection { true }

	regulate_broadcast do |policy|
		policy.send_all.to(self.users.any? ? self.users : [acting_user])
    # policy.send_all.to(::Application)
	end


  allow_create { acting_user.present? }
  # allow_update { acting_user == self.user }
end