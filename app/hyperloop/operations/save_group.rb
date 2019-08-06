class SaveGroup < Hyperloop::Operation
	param id: nil, nils: true
  param name: nil, nils: true
  param desc: nil, nils: true
  param kinds: [], nils: true
  param photo_uri: nil, nils: true

  [:name, :desc].each do |field|
    add_error field, :blank, "nie może być puste" do
      params.try(field).blank? || params.try(field).empty?
    end
	end

	add_error :name, :max, "maksymalnie 40 znaków" do
		params.name.size > 40
	end

	step do
		if params.id.present?
			group = Group.find(params.id)
			group.name = params.name
			group.desc = params.desc
			if params.photo_uri.present?
				group.photo_uri = params.photo_uri
			end
		else
			group = Group.new(name: params.name, desc: params.desc, kinds: params.kinds, photo_uri: params.photo_uri)
		end

    group.save.then
  end
  step do |response|
    unless response[:success]
      raise ArgumentError, response[:saved_models].first[3]
    end
    return Group.new(response[:saved_models].first[2])
  end
end

# if params.id.present?
# 	hotline = Hotline.find(params.id)
# 	hotline.content = params.content
# 	hotline.is_anonymous = params.is_anonymous
# 	hotline.user_id = params.acting_user.try(:id)
# 	hotline.city = params.city || params.acting_user.try(:city)
# 	hotline.lon = params.lon || params.acting_user.try(:lon)
# 	hotline.lat = params.lat || params.acting_user.try(:lat)
# else