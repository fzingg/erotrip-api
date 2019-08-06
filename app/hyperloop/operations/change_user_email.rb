class ChangeUserEmail < Hyperloop::ControllerOp; end
class ChangeUserEmail < Hyperloop::ControllerOp
	param :password, nils: false
	param :new_email, nils: false

	step do
		if acting_user
			if acting_user.valid_password?(params.password)
				acting_user.email = params.new_email
				acting_user.save
			else
				raise "Przepraszamy, nie udało się zmienić adresu e-mail"
			end
		else
			raise "Musisz być zalogowany/a"
		end
	end
end unless RUBY_ENGINE == 'opal'