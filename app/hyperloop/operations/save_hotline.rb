class SaveHotline < Hyperloop::Operation
  param content: nil, nils: true
  param is_anonymous: nil, nils: true
  param city: nil, nils: true # CurrentUserStore.current_user.try(:city) || ''
  param lon: nil, nils: true # CurrentUserStore.current_user.try(:lon)
  param lat: nil, nils: true # CurrentUserStore.current_user.try(:lat)
  param :acting_user
  param id: nil, nils: true

  [:content].each do |field|
    add_error field, :blank, "nie może być puste" do
      params.try(field).blank? || params.try(field).empty?
    end
  end

  step do
    puts "IS THERE ACTING USER? #{params.acting_user.inspect}"
    if params.id.present?
      hotline = Hotline.find(params.id)
      hotline.content = params.content
      hotline.is_anonymous = params.is_anonymous
      hotline.user_id = params.acting_user.try(:id)
      hotline.city = params.city || params.acting_user.try(:city)
      hotline.lon = params.lon || params.acting_user.try(:lon)
      hotline.lat = params.lat || params.acting_user.try(:lat)
    else
      hotline = Hotline.new(
        content: params.content,
        is_anonymous: params.is_anonymous,
        user_id: params.acting_user.try(:id), # CurrentUserStore.current_user.try(:id)
        city: params.city || params.acting_user.try(:city),
        lon: params.lon || params.acting_user.try(:lon),
        lat: params.lat || params.acting_user.try(:lat)
      )
    end
    hotline.save.then
  end
  step do |response|
    puts response.inspect
    unless response[:success]
      if params.id.present?
        hotline = Hotline.find(params.id)
        hotline.revert
      end
      raise ArgumentError, response[:saved_models].first[3]
    end
    return Hotline.new(response[:saved_models].first[2])
  end
end