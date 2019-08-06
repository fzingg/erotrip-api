class SaveUserAvatar < Hyperloop::Operation
	# regulate_class_connection { true }
	# always_allow_connection

	param :user_id, nils: false
	param :avatar_uri, nils: false
	
	step do
		user = User.find params.user_id
		user.avatar_uri = params.avatar_uri
		user.save().then {}
  end
	step do |response|
		return response
  end
end