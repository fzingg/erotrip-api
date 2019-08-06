class ProcessLogout < Hyperloop::ControllerOp
  outbound :old_session
  outbound :new_session

  step { @old_session = session_channel }
  step {
    puts "\n\n user_session: #{user_session.inspect} \n\n"
    sign_out
  }
  step do |response|
    params.old_session = @old_session
    params.new_session = session_channel
    puts "\n session: #{session.inspect} \n"
    puts "\n\n\n ProcessLogout response --> #{response} \n\n\n"
    puts "\n\n\n session_channel  --> #{session_channel} ::: old channel --> #{@old_session} \n\n\n"
  end
  # dispatch_to { current_session }
  dispatch_to { @old_session }
  # dispatch_to Hyperloop::Application

  # failed do |response|
  #   puts 'NIE POSZLO W OPERACJI'
  #   puts JSON.parse(response.body).inspect
  #   # {data: JSON.parse(response.body)}
  #   # Object.new({data: JSON.parse(response.body)})
  #   response
  # end
end