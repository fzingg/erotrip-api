class ChangeUserPassword < Hyperloop::ControllerOp; end
class ChangeUserPassword < Hyperloop::ControllerOp
	param :old_password, nils: false
	param :new_password, nils: false
	param :new_password_confirmation, nils: false

	step do
		if acting_user
			if acting_user.valid_password?(params.old_password) && params.new_password == params.new_password_confirmation
				acting_user.update_attribute(:password, params.new_password)
				sign_in(acting_user, bypass: true)
			else
				raise "Sorry, We could not change your password"
			end
		else
			raise "You must be signed in"
		end
	end
end unless RUBY_ENGINE == 'opal'