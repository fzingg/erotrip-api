class SaveUserIdealPartner < Hyperloop::Operation
	param :user_id, nils: false
	param :ideal_partner, nils: true
	
	add_error :about_me, nil, "Może zawierać maksymalnie 500 znaków" do
		# validate about_me length
		false
	end

	step do
		user = User.find params.user_id
		user["ideal_partner"] = params.ideal_partner
		user.save().then {}
  end
	step do |response|
		return response
  end
end