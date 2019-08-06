class SaveUserInterests < Hyperloop::ServerOp
	param :user_id, nils: false
	param :interest_ids, nils: true
	param :acting_user

	step do
		user = User.find params.user_id
		user.interest_ids = params.interest_ids
		user.save
  end
	step do |response|
		response
  end
end