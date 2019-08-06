class PhotoPolicy
	allow_create { acting_user != nil }
	allow_update { acting_user && acting_user.is_admin? || acting_user.id == user.id }
	allow_destroy { acting_user && acting_user.is_admin? || acting_user.id == user.id }

	NEVER_SEND = [:file_uploader]
		# PUBLIC_ATTRIBUTES = [:user_id, :created_at, :updated_at, :url, :thumbnail_url, :is_private]


	regulate_broadcast do |policy|

		if !is_private?
			policy.send_all_but(*NEVER_SEND, :created_at).to(::Application)
		elsif is_private?
			policy.send_all_but(*NEVER_SEND, :created_at, :url, :thumbnail_url).to(::Application)
		end
		policy.send_all_but(*NEVER_SEND).to(user.private_photo_permissions_users, user) if is_private?
		policy.send_all_but(*NEVER_SEND).to(acting_user) if acting_user && acting_user.is_admin?
	end
end