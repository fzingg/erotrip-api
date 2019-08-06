class CheckPrivatePhotosPermission < Hyperloop::ControllerOp; end
class CheckPrivatePhotosPermission < Hyperloop::ControllerOp
	outbound :response
	param :user_id, nils: false
	param :owner_id, nils: false

	step do
		permitted = AccessPermission.private_photos_granted.where(owner_id: params.owner_id).where(permitted_id: params.user_id).first
	end
	step do |response|
		if !response
			false
		else
			true
		end
	end
end unless RUBY_ENGINE == 'opal'