class DeleteUser < Hyperloop::ControllerOp; end
class DeleteUser < Hyperloop::ControllerOp
	param :user_id, nils: false
	param :pin, nils: false

	step do
		user = User.find(params.user_id)
		pin = params.pin.class == 'Integer' ? params.pin : params.pin.to_i
		if user && pin == user.pin
			user.destroy
		else
			raise "Nieprawidłowy PIN"
		end
  end

	step do |response|
		response
  end

end unless RUBY_ENGINE == 'opal'