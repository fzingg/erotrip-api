class AdminPolicy
	regulate_class_connection { self && self.is_admin? }

	# regulate_all_broadcasts do |policy|
	# 	policy.send_all_but(:avatar_uploader, :verification_photo_uploader, :password_digest).to(::Admin)
	# end
end
