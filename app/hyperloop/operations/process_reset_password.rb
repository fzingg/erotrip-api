class ProcessResetPassword < Hyperloop::ServerOp
  param :email, default: nil, nils: true
  param :pin, default: nil, nils: true
  param :password, default: nil, nils: true
  param :password_confirmation, default: nil, nils: true
  param :acting_user, default: nil, nils: true

  [:email, :pin, :password, :password_confirmation].each do |field|
    err_msg = if field == 'email'
      'e-mail nie może być pusty'
    elsif  field == 'pin'
      'pin nie może być pusty'
    elsif  field == 'password'
      'hasło nie może być puste'
    elsif  field == 'password_confirmation'
      'potwierdzenie hasła nie może być puste'
    end

    add_error field, :blank, err_msg do
      params.try(field).blank?
    end
  end

  failed do |exception|
    exception.errors.message
  end
  step do
    User.find_by(email: params.email.downcase, pin: params.pin)
  end
  step do |user|
    fail if user.blank?
    user
  end
  failed do |exception|
    if exception.present? && exception.is_a?(Hash)
      exception
    else
      { base: 'Podałeś/aś niepoprawny e-mail lub PIN' }
    end
  end
  step do |user|
    user.password = params.password
    {status: user.save, user: user}
  end
  step do |response|
    unless response[:status]
      raise ArgumentError, response[:user].errors.messages.to_json
    end
    true
  end
  failed do |exception|
    if exception.present? && exception.is_a?(Hash)
      exception
    else
      err = { base: 'Nie udało się zrestartować hasła' }
      err = err.deep_merge(JSON.parse(exception.message.gsub('=>', ':')))
      err
    end
  end
end