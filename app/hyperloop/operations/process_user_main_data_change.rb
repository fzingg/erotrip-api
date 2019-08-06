class ProcessUserMainDataChange < Hyperloop::Operation
	param :kind, nils: true
	param :name, nils: true
	param :birth_year, nils: true
	param :name_second_person, nils: true
	param :birth_year_second_person, nils: true
	param :city, nils: true
	param :lon, nils: true
	param :lat, nils: true

	[:kind, :name, :birth_year, :city, :lon, :lat].each do |field|
		add_error field, :blank, "nie może być puste" do
			params.try(field).blank?
		end
	end

	[:name_second_person, :birth_year_second_person].each do |field|
		add_error field, :blank, "nie może być puste" do
			if ['couple', 'women_couple', 'men_couple'].include?(params.try(:kind))
				params.try(field).blank?
			else
				false
			end
		end
	end

	step do
		ChangeUserMainData.run(
			kind: params.kind,
			name: params.name,
			birth_year: params.birth_year,
			name_second_person: params.name_second_person,
			birth_year_second_person: params.birth_year_second_person,
			city: params.city,
			lon: params.lon,
			lat: params.lat,

			# email: params.email,
			# password: params.password,

			# old_pin: params.old_pin,
			# new_pin: params.new_pin,
			# new_pin_confirmation: params.new_pin_confirmation,

			# old_password: params.old_password,
			# new_password: params.new_password,
			# new_password_confirmation: params.new_password_confirmation
		)
	end
end