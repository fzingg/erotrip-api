class RemoveGroup < Hyperloop::ControllerOp; end
class RemoveGroup < Hyperloop::ControllerOp
	param group_id: nil, nils: false

	step do
		if !acting_user || !acting_user.is_admin?
			raise Hyperloop::AccessViolation
		else
			Group.find(params.group_id)
		end
	end

	step do |group|
		if group
			group.destroy
		else
			false
		end
	end

end unless RUBY_ENGINE == 'opal'