class SaveAccessPermission < Hyperloop::ServerOp
	# outbound :response
	param :owner_id, nils: false
	param :permitted_id, nils: false
	param :profile_granted, nils: false
	param :profile_requested, nils: false
	param :acting_user


	step do
		perm = AccessPermission.where(owner_id: params.acting_user.id, permitted_id: params.permitted_id).first_or_initialize
		perm.profile_granted = params.profile_granted
		perm.profile_requested = params.profile_requested

		perm.save
	end
end