class ProcessSignUp < Hyperloop::Operation
  param :kind
  param terms_acceptation: false
  param :name
  param :birth_year
  param :name_second_person, default: '', nils: true
  param :birth_year_second_person, default: nil, nils: true
  param :email
  param :city
  param :lon
  param :lat
  param :password
  param :password_confirmation
  # param :pin
  # param :pin_confirmation

  param response: {}

  add_error :kind, :blank, "nie może być puste" do
    params.kind.blank?
  end

  [:kind, :name, :birth_year, :email, :city, :password, :password_confirmation].each do |field|
    add_error field, :blank, "nie może być puste" do
      params.try(field).blank?
    end
  end

  [:lon, :lat].each do |field|
    add_error :city, :blank, "nie może być puste" do
      params.try(field).blank?
    end
  end

  add_error :name_second_person, :blank, "nie może być puste" do
    params.name_second_person.blank? && params.kind.present? && !['man', 'woman', 'tgsv'].include?(params.kind)
  end

	add_error :birth_year_second_person, :blank, "nie może być puste" do
    params.birth_year_second_person.blank? && params.kind.present? && !['man', 'woman', 'tgsv'].include?(params.kind)
  end

  add_error :password_confirmation, :same_as, "hasła nie są takie same" do
    params.password != params.password_confirmation
  end

  # add_error :pin_confirmation, :same_as, "PINy nie są takie same" do
  #   params.pin != params.pin_confirmation
  # end

  add_error :terms_acceptation, :blank, "musi zostać zaakceptowane" do
    !params.terms_acceptation
  end

  step do
    payload = { user: {
      kind: params.kind,
      name: params.name,
      birth_year: params.birth_year,
      name_second_person: params.name_second_person,
      birth_year_second_person: params.birth_year_second_person,
      email: params.email,
      city: params.city,
      lon: params.lon,
      lat: params.lat,
      password: params.password,
			password_confirmation: params.password_confirmation,
			last_trips_visit_at: Time.now,
			last_users_visit_at: Time.now,
			last_peepers_visit_at: Time.now,
      # pin: params.pin,
      # pin_confirmation: params.pin_confirmation,
      terms_acceptation: params.terms_acceptation
    } }
    result = ProcessRegistration.run(payload: payload)
    result
      .then do |r|
        puts "then"
        puts "result.rejected? - #{result.rejected?} :::::: result.error - #{result.error} :::::"
      end
      .fail do |e|
        errors_hash = JSON.parse e.message.gsub('=>', ':')
        errors_hash.each do |key, value|
          add_error key.to_sym, :same_as, value.join do
            true
          end
        end
        @last_result = ValidationException.new(@errors)
      end
  end
end