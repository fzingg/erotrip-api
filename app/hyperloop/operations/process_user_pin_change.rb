class ProcessUserPinChange < Hyperloop::Operation
	param :old_pin
	param :new_pin
	param :new_pin_confirmation

	[:old_pin, :new_pin, :new_pin_confirmation].each do |field|
    add_error field, :blank, "nie może być puste" do
      params.try(field).blank?
    end
	end

	[:old_pin, :new_pin, :new_pin_confirmation].each do |field|
    add_error field, :min, "musi mieć co najmniej 4 znaki" do
      params.try(field).try(:size).try(:<, 4)
    end
	end

	[:new_pin, :new_pin_confirmation].each do |field|
		add_error field, :min, "musi składać się wyłącznie z cyfr" do
      params.try(field).present? && !params.try(field).match('^[0-9]+$')
    end
	end

	add_error :new_pin_confirmation, :same_as, "musi być takie same jak nowy pin" do
		if params.try(:new_pin_confirmation) && params.try(:new_pin)
			params.try(:new_pin_confirmation) != params.try(:new_pin)
		else
			false
		end
	end

	step do
		ChangeUserPin.run(
			old_pin: params.old_pin,
			new_pin: params.new_pin,
			new_pin_confirmation: params.new_pin_confirmation
		)
	end

end