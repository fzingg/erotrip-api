class RemoveTrip < Hyperloop::Operation
  param id: nil

  step do
    trip = Trip.find(params.id)
    trip.destroy.then
  end
  step do |response|
    unless response[:success]
      puts response.inspect
      trip.revert
      raise ArgumentError, response[:saved_models].first[3]
    end
    return {}
  end
end