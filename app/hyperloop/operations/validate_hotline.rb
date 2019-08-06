class ValidateHotline < Hyperloop::ServerOp
  param content: nil, nils: true
  param is_anonymous: nil, nils: true
  param city: nil, nils: true
  param lon: nil, nils: true
  param lat: nil, nils: true
  param acting_user: nil, nils: true
  param id: nil, nils: true

  step do
    hotline = Hotline.new
    hotline.omit_user_validation = true
    hotline.content = params.content
    hotline.is_anonymous = params.is_anonymous
    hotline.city = params.city || params.acting_user.try(:city)
    hotline.lon = params.lon || params.acting_user.try(:lon)
    hotline.lat = params.lat || params.acting_user.try(:lat)

    {status: hotline.valid?, hotline: hotline}

  end
  step do |response|
    unless response[:status]
      raise ArgumentError, response[:hotline].errors.messages.to_json
    end
    response[:hotline]
  end
end
