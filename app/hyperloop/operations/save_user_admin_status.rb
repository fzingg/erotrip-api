class SaveUserAdminStatus < Hyperloop::Operation
	param :user_id, nils: false
	
	step do
		user = User.find params.user_id
		user["is_admin"] = !user["is_admin"]
		user.save().then {}
  end
	step do |response|
		return response
  end
end