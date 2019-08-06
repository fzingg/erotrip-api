class RoomUserPolicy
  # always_allow_connect # regulate_class_connection { true }

	regulate_broadcast do |policy|
		# policy.send_all.to(self.user)
    policy.send_all.to( [self.user, self.dependent_resource_owner].compact.uniq )
	end


  allow_create { acting_user.present? }
  # allow_update { acting_user == self.user }
end