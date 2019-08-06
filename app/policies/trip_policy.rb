class TripPolicy
	regulate_broadcast do |policy|
		policy.send_all.to(::Application)
	end

  allow_create { acting_user.present? }
  allow_update { acting_user == self.user }
  allow_destroy { acting_user == self.user }
end