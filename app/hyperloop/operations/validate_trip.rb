class ValidateTrip < Hyperloop::ServerOp
  param description: nil, nils: true
  param destinations: [], nils: true
  param acting_user: nil, nils: true
  param arrival_time: nil, nils: true
  param is_anonymous: nil, nils: true
  param id: nil, nils: true

   step do
    trip = Trip.new
    trip.description = params.description
    trip.omit_user_validation = true
    trip.destinations = { data: params.destinations['data'] }
    trip.arrival_time = params.arrival_time
    trip.is_anonymous = !!params.is_anonymous

    {status: trip.valid?, trip: trip}

  end
  step do |response|
    unless response[:status]
      raise ArgumentError, response[:trip].errors.messages.to_json
    end
    response[:trip]
  end
end
# if RUBY_ENGINE == "opal"