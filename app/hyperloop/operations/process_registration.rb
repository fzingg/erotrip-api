class ProcessRegistration < Hyperloop::ControllerOp
  param :payload
  outbound :response

	step do
    @user = User.create(params.payload['user'])
  end

  step {
    if @user.persisted?
      @user.remember_me = true
      sign_in(:user, @user)
    else
      @errors = @user.errors
      fail
    end
  }

  failed { |e|
    @errors.messages.to_json
  }

  step do |response|
    if response != true
      response[:verification_photo_uploader] = nil
      response[:avatar_uploader] = nil
    end
    params.response = response
  end

  dispatch_to { session_channel }
end