class DeleteUserPhoto < Hyperloop::ControllerOp; end
class DeleteUserPhoto < Hyperloop::ControllerOp
	param :photo_id, nils: false

	step do
		photo = Photo.find_by_id(params.photo_id)
		if photo && acting_user && (acting_user.is_admin? || photo.user.id == acting_user.id)
			photo.destroy

		else
			raise Hyperloop::AccessViolation
		end
  end
	step do |response|
		response
  end
end unless RUBY_ENGINE == 'opal'