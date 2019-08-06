class SaveUserPin < Hyperloop::ControllerOp; end
class SaveUserPin < Hyperloop::ControllerOp
	param :pin, nils: false

	step do
		if acting_user
			acting_user.pin = params.pin
			acting_user.save
		end
	end
end unless RUBY_ENGINE == "opal"