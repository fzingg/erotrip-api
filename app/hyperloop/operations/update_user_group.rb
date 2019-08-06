class UpdateUserGroup < Hyperloop::ServerOp
  param user_id: nil, nils: false
  param group_id: nil, nils: false
  param is_public: nil, nils: false
  param :acting_user

	step do
    UserGroup.unscoped.where(user_id: params.user_id, group_id: params.group_id).first
  end

	step do |response|
		if response
			response.update(is_public: params.is_public)
		else
			nil
		end
  end

  failed do |response|
    puts "failed response", response
    response
  end
end