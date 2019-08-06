class SaveUserPhoto < Hyperloop::Operation
	param :user_id, nils: false
	param :photo_uri, nils: false

	step do
		# user = User.find params.user_id
		Photo.create(file_uri: params.photo_uri, user_id: params.user_id).then {}
		# photo.file_uri = params.photo_uri
		# user.photos << photo
		# user.save().then {}
  end
	step do |response|
		return response
  end
end