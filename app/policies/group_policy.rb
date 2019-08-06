class GroupPolicy
	allow_create { acting_user }
	allow_update { acting_user && acting_user.is_admin? }
	allow_destroy { acting_user && acting_user.is_admin? }

	regulate_broadcast do |policy|
		policy.send_all_but(:photo_uploader).to(::Application)
	end
end