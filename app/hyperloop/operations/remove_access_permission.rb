class RemoveAccessPermission < Hyperloop::ControllerOp; end
class RemoveAccessPermission < Hyperloop::ControllerOp
	# outbound :response
	param :permitted_id, nils: false

	step do
		if !acting_user
			raise Hyperloop::AccessViolation
		end
	end

	step do
		perm = AccessPermission.where(owner_id: acting_user.id, permitted_id: params.permitted_id).first

		if perm
			perm.destroy
		else
			true
		end
	end
end unless RUBY_ENGINE == 'opal'