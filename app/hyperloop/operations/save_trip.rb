# class SaveTrip < Hyperloop::Operation; end
class SaveTrip < Hyperloop::ServerOp
  param description: nil, nils: true
  param destinations: [], nils: true
  param :acting_user
  param arrival_time: nil, nils: true
  param is_anonymous: nil, nils: true
  param id: nil, nils: true

   step do
    #size = params.destinations['data'].size
   # destinations = params.destinations['data'][1...(size-1)].select { |item| (item['city'] && item['lat'] && item['lon']) } 
    #destinations.insert(0, params.destinations['data'][0])
    #byebug
    
    if params.id.present? && params.id.to_i > 0
      trip = Trip.find(params.id)
    else
      trip = Trip.new
    end
    puts "mamy tripa, #{trip.inspect}"
    trip.description = params.description
    puts "mamy description #{trip.description.inspect}"
    trip.user_id = trip.user_id || params.acting_user.try(:id)
    puts "mamy user_id #{trip.user_id.inspect}"
    trip.destinations = { data: params.destinations['data'] }
    puts "mamy destinations #{trip.destinations.inspect}"
    trip.arrival_time = params.arrival_time
    puts "mamy arrival_time #{trip.arrival_time.inspect}"
    trip.is_anonymous = !!params.is_anonymous
    puts "mamy is_anonymous #{trip.is_anonymous.inspect}"

    {status: trip.save, trip: trip}

  end
  step do |response|
    puts "mamy save response #{response.inspect}"
    unless response[:status]
      raise ArgumentError, response[:trip].errors.messages.to_json
    end
    response[:trip]
  end
end
# if RUBY_ENGINE == "opal"