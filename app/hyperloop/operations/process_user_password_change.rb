class ProcessUserPasswordChange < Hyperloop::Operation
	param :old_password
	param :new_password
	param :new_password_confirmation

	[:old_password, :new_password, :new_password_confirmation].each do |field|
    add_error field, :blank, "nie może być puste" do
      params.try(field).blank?
    end
	end

	add_error :new_password_confirmation, :same_as, "hasła muszą się zgadzać" do
		if params.try(:new_password_confirmation) && params.try(:new_password)
			params.try(:new_password_confirmation) != params.try(:new_password)
		else
			false
		end
	end

	step do
		ChangeUserPassword.run(
			old_password: params.old_password,
			new_password: params.new_password,
			new_password_confirmation: params.new_password_confirmation
		)
	end

end