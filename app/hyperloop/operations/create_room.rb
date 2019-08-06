class CreateRoom < Hyperloop::ServerOp
  param context_type: nil
  param context_id: nil
  param hotline_id: nil, nils: true
  param trip_id: nil, nils: true
  param user_id: nil, nils: true
  param acting_user: nil, nils: false

  step do
    if params.context_type.present? && params.context_id.present?
      context = params.context_type.classify.constantize.find(params.context_id)
    else
      context = nil
    end
    room = Room.new(
      owner_id: params.user_id || context.try(:user_id) || params.acting_user.try(:id),
      # user_ids: [params.acting_user.try(:id), context.try(:user_id), params.user_id].compact.uniq,
      hotline_id: params.hotline_id,
      trip_id: params.trip_id
    )
    room["#{params.context_type.downcase}_id"] = params.context_id if params.context_type.downcase != 'user'
    puts room.inspect
    {status: room.save, room: room}
  end
  step do |response|
    unless response[:status]
      puts "ERROR: #{response[:status]}"
      raise ArgumentError, response[:room].errors.messages.to_json
    end
    response[:room]
  end
end