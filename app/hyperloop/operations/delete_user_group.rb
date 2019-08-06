class DeleteUserGroup < Hyperloop::ControllerOp; end
class DeleteUserGroup < Hyperloop::ControllerOp
  param group_id: nil, nils: true
	param user_id: nil, nils: true
	param acting_user: nil, nils: true

	step do
		if acting_user && acting_user.id == params.user_id
			UserGroup.unscoped.where(user_id: params.user_id, group_id: params.group_id).first
		else
			nil
		end
	end

	step do |user_group|
		if user_group
			user_group.destroy
		else
			nil
		end
	end
end unless RUBY_ENGINE == "opal"