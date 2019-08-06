class DeleteVerificationPhoto < Hyperloop::ControllerOp; end
class DeleteVerificationPhoto < Hyperloop::ControllerOp
	param :user_id, nils: false

	step do
		user = User.find_by_id(params.user_id)
		puts "DATA: #{user}, #{acting_user}, #{acting_user.is_admin?}, #{user.id == acting_user.id}"
		if user && acting_user && (acting_user.is_admin? || user.id == acting_user.id)
			user.update_attributes({
				verification_photo_updated_at: nil,
				rejection_message: nil,
				is_verified: false,
				verified_at: nil,
				verification_photo_uploader: nil
			})
		else
			raise Hyperloop::AccessViolation
		end
  end
	step do |response|
		response
  end
end unless RUBY_ENGINE == 'opal'