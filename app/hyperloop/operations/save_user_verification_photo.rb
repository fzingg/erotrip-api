class SaveUserVerificationPhoto < Hyperloop::Operation
	# regulate_class_connection { true }
	# always_allow_connection

	param :user_id, nils: false
	param :verification_photo_uri, nils: false
	param :acting_user

	step do
		user = User.find params.user_id
		user.verification_photo_uri = params.verification_photo_uri
		user.save().then {}
  end
	step do |response|
		SaveAlert.run({ reason: 'verification', resource_type: 'User', resource_id: params.user_id, acting_user: params.acting_user })
		return response
  	end
end