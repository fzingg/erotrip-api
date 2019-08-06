class ToggleAccess < Hyperloop::ControllerOp; end
class ToggleAccess < Hyperloop::ControllerOp
	outbound :response
	param :type, nils: false
	param :permitted_id, nils: false
	param :perm_state, nils: false

	step do
		if !acting_user
			raise Hyperloop::AccessViolation
		end
	end

	step do
		perm = AccessPermission.where(owner_id: acting_user.id, permitted_id: params.permitted_id).first_or_initialize do |p|
			p.permitted_id = params.permitted_id
			p.owner_id = acting_user.id
		end

		if params.type == "private_photos"
			perm.private_photos_granted = params.perm_state
		elsif params.type == "profile"
			perm.private_photos_granted = false if (params.perm_state == false && perm.private_photos_granted == true)
			perm.profile_granted = params.perm_state
		end

		perm.save
	end
end unless RUBY_ENGINE == 'opal'