class ProcessLogin < Hyperloop::ControllerOp
  param :email, default: nil, nils: true
  param :password, default: nil, nils: true
  outbound :response
  outbound :old_session
  outbound :new_session

  add_error :email, :blank, "email nie może być pusty" do
    params.email.blank?
  end

  add_error :password, :blank, "hasło nie może być puste" do
    params.password.blank?
  end

  add_error(:email, :does_not_exist, 'niepoprawny adres e-mail lub hasło') { !(@user = User.find_by_email(params.email.downcase)) }
  add_error(:password, :is_incorrect, 'niepoprawny adres e-mail lub hasło') { User.find_by_email(params.email.downcase) && !User.find_by_email(params.email.downcase).try(:valid_password?, params.password)  }

  add_error :email, :invalid, "niepoprawny format adresu email" do
    r = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    (r =~ params.email).blank?
  end
  step { @old_session = session_channel }
  step { @user.remember_me = true }
	step {
    sign_in(:user, @user)
  }
	step do |response|
    puts "\n session: #{session.inspect} \n"
    puts "\n\n user_session: #{user_session.inspect} \n\n"
    params.old_session = @old_session
    params.new_session = session_channel
    puts "\n\n\n ProcessLogout response --> #{response} \n\n\n"
    puts "\n\n\n session_channel  --> #{session_channel} ::: old channel --> #{@old_session} \n\n\n"
    if response != true
      response[:verification_photo_uploader] = nil
      response[:avatar_uploader] = nil
    end
    params.response = response
  end

	dispatch_to { @old_session }
	step { params.response }
end