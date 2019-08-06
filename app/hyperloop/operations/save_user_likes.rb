class SaveUserLikes < Hyperloop::Operation
	param :user_id, nils: false
	param :likes, nils: true
	
	add_error :about_me, nil, "Może zawierać maksymalnie 500 znaków" do
		# validate about_me length
		false
	end

	step do
		user = User.find params.user_id
		user["likes"] = params.likes
		user.save().then {}
  end
	step do |response|
		return response
  end
end