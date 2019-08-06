class UserPolicy
	allow_update { true }
	allow_create { true }
	allow_destroy { true }
	NEVER_SEND = [:avatar_uploader, :verification_photo_uploader, :encrypted_password, :reset_password_sent_at]

	# W scopie connection self to zalogowany uzytkownik (acting_user)
	# regulate_class_connection { self }
	regulate_instance_connections { self }

	# W scopie regulate_broadcasts self odnosi sie do obiektu ktory zostal zmieniony
	regulate_broadcast do |policy|
		regulate_users = [:visits]

		# Privacy settings
		# regulate_users << :id if is_private? How to restrict every attribute?
		regulate_users << :birth_year unless privacy_settings["show_age"]
		regulate_users << :birth_year_second_person unless privacy_settings["show_age"]
		regulate_users << :groups unless privacy_settings["show_groups"]
		regulate_users << :photos unless privacy_settings["show_gallery"]
		regulate_users << :current_sign_in_at unless privacy_settings["show_date"]
		regulate_users << :last_sign_in_at unless privacy_settings["show_date"]
		#	regulate_users << ( ? ) unless privacy_settings["show_online"]

		policy.send_all_but(*NEVER_SEND, *regulate_users).to(::Application)
		policy.send_all_but(*NEVER_SEND).to(::Admin)
		policy.send_all_but(*NEVER_SEND).to(self)
	end
end