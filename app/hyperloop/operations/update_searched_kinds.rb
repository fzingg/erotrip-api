class UpdateSearchedKinds < Hyperloop::ControllerOp; end
class UpdateSearchedKinds < Hyperloop::ControllerOp
	param :searched_kinds, nils: true

	step do
		if acting_user.present?
			acting_user.update_attribute(:searched_kinds, params.searched_kinds)
			true
		else
			false
		end
	end
end unless RUBY_ENGINE == 'opal'