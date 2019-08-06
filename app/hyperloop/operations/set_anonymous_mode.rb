class SetAnonymousMode < Hyperloop::ControllerOp; end
class SetAnonymousMode < Hyperloop::ControllerOp
  param is_private: nil, nils: false

	step do
		if acting_user
			acting_user.is_private = params.is_private
			acting_user.save
		else
			raise Hyperloop::AccessViolation
		end
  end

	step do |response|
		response
	end

	failed do |e|
		"Operacja niedozwolona"
	end
end unless RUBY_ENGINE == 'opal'