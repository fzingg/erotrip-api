class UpdatePhotoMode < Hyperloop::ControllerOp; end
class UpdatePhotoMode < Hyperloop::ControllerOp
	param :photo_id, nils: false

	step do
		photo = Photo.find_by_id(params.photo_id)
		if photo && acting_user && (acting_user.is_admin? || acting_user.id == photo.user.id)
			photo.is_private = !photo.is_private
			photo.save
		else
			raise Hyperloop::AccessViolation
		end
  end
	step do |response|
		response
  end
end unless RUBY_ENGINE == 'opal'