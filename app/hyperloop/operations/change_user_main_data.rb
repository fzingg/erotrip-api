class ChangeUserMainData < Hyperloop::ControllerOp; end
class ChangeUserMainData < Hyperloop::ControllerOp
	param :kind, nils: true
	param :name, nils: true
	param :birth_year, nils: true
	param :name_second_person, nils: true
	param :birth_year_second_person, nils: true
	param :city, nils: true
	param :lon, nils: true
	param :lat, nils: true

	step do
		if acting_user
			acting_user.kind = params.kind
			acting_user.name = params.name
			acting_user.birth_year = params.birth_year
			acting_user.name_second_person = params.name_second_person
			acting_user.birth_year_second_person = params.birth_year_second_person
			acting_user.city = params.city
			acting_user.lon = params.lon
			acting_user.lat = params.lat
			acting_user.save
		else
			raise "Musisz być zalogowany/a"
		end
	end
end unless RUBY_ENGINE == 'opal'