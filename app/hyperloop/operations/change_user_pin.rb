class ChangeUserPin < Hyperloop::ControllerOp; end
class ChangeUserPin < Hyperloop::ControllerOp
	param :old_pin, nils: false
	param :new_pin, nils: false
	param :new_pin_confirmation, nils: false

	step do
		if acting_user
			if acting_user.pin && acting_user.pin == params.old_pin.to_i && params.new_pin.to_i == params.new_pin_confirmation.to_i
				acting_user.pin = params.new_pin.to_i
				acting_user.save
			else
				raise "Sorry, We could not change your pin"
			end
		else
			raise "You must be signed in"
		end
	end
end unless RUBY_ENGINE == 'opal'