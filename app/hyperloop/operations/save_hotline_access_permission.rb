class SaveHotlineAccessPermission < Hyperloop::ServerOp
	# outbound :response
	param :hotline_id, nils: false
	param :owner_id, nils: false
	param :permitted_id, nils: false
	param :is_permitted, nils: false
	param :acting_user


	step do
		perm = HotlineAccessPermission.where(hotline_id: params.hotline_id, owner_id: params.acting_user.id, permitted_id: params.permitted_id).first_or_initialize
		perm.is_permitted = params.is_permitted

		perm.save
	end
end