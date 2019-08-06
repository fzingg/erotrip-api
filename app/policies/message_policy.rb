class MessagePolicy
  # always_allow_connect # regulate_class_connection { true }

	regulate_broadcast do |policy|
		policy.send_all_but(:file_uploader, :file_uploader_url).to(self.room.users.any? ? self.room.users : [acting_user])
  end
  # policy.send_all.to(::Application)


  allow_create { acting_user.present? }
  allow_update { acting_user == self.user }
end