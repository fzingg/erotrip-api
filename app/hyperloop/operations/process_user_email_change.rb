class ProcessUserEmailChange < Hyperloop::Operation
	param :password
	param :new_email

	[:password, :new_email].each do |field|
    add_error field, :blank, "nie może być puste" do
      params.try(field).blank?
    end
	end

	[:new_email].each do |field|
		add_error field, :email, "adres jest niepoprawny" do
			if params.try(field)
				!params.try(field).try(:match, /\S+@\S+\.\S+/)
			else
				false
			end
    end
	end

	step do
		ChangeUserEmail.run(
			password: params.password,
			new_email: params.new_email
		)
	end

end