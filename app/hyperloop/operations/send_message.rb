class SendMessage < Hyperloop::ServerOp
  param content: nil, nils: true
  param room_id: nil, nils: true
  param file_uri: nil, nils: true
  param acting_user: nil, nils: true


  step do
    message = Message.new(content: params.content, room_id: params.room_id, file_uri: params.file_uri, user_id: params.acting_user.try(:id))
    {status: message.save, item: message}
  end

  step do |response|
    puts "mamy save response #{response.inspect}"
    unless response[:status]
      raise ArgumentError, response[:item].errors.messages.to_json
    else
      response[:item].handle_room_users
      AfterSendMessage.run(message_id: response[:item].try(:id))
    end
    response[:item]
  end


  #   HTTP.post('/messages', payload: { message: { file_uri: params.file_uri, content: params.content, room_id: params.room_id, user_id: params.acting_user.try(:id) } }).then do |response|
  #     AfterSendMessage.run(message_id: response.json["id"])
  #   end
  # end
end