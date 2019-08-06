class SaveUserAboutMe < Hyperloop::ServerOp
	param :user_id, nils: false
	param :about_me, nils: true
	param :searched_kinds, nils: true
	param :body, nils: true
	param :is_smoker, nils: true
	param :is_drinker, nils: true
	param :weight, nils: true
	param :height, nils: true
	# param :interest_ids, nils: true
	param :acting_user

	add_error :about_me, :invalid_length, "Może zawierać maksymalnie 200 znaków" do
		params.about_me && params.about_me.try(:size).try(:>, 200)
	end

	step do
		user = User.find(params.user_id)
		user.about_me = params.about_me
		user.searched_kinds = params.searched_kinds
		user.body = params.body
		user.is_smoker = params.is_smoker
		user.is_drinker = params.is_drinker
		user.weight = params.weight
		user.height = params.height
		# user.interest_ids = params.interest_ids
		user
	end

	step do |user|
		if user.present?
			if user.predefined_users.blank?
				user.predefined_users = {}
			end

			if user.predefined_users["only_users_search_kind_in"].blank?
				user.predefined_users["only_users_search_kind_in"] = []
			end

			if (user.predefined_users["only_users_search_kind_in"].try(:size) != params.searched_kinds.try(:size)) || ((user.predefined_users["only_users_search_kind_in"] | params.searched_kinds).try(:size) != user.predefined_users["only_users_search_kind_in"].try(:size))
				user.predefined_users["only_users_search_kind_in"] = params.searched_kinds
			end

			user.save
		else
			false
		end
	end

	step do |response|
		response
  end
end