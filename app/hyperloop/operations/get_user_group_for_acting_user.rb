class GetUserGroupForActingUser < Hyperloop::ControllerOp; end
class GetUserGroupForActingUser < Hyperloop::ControllerOp
	param :group_id, nils: false

	step do
		if !acting_user
			nil
		else
			UserGroup.unscoped.where(user_id: acting_user.id).where(group_id: params.group_id).first
		end
	end
	step do |user_group|
		if user_group
			old_visit_time = user_group.last_visit_at
			user_group.last_visit_at = DateTime.now
			user_group.save
			old_visit_time
		else
			nil
		end
	end
end unless RUBY_ENGINE == 'opal'