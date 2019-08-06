class RequestAccess < Hyperloop::ControllerOp; end
class RequestAccess < Hyperloop::ControllerOp
	outbound :response
	param :type, nils: false
	param :owner_id, nils: false

	step do
		if !acting_user
			raise Hyperloop::AccessViolation
		end
	end

	step do
		perm = AccessPermission.where(owner_id: params.owner_id, permitted_id: acting_user.id).first_or_initialize do |p|
			p.permitted_id = acting_user.id
			p.owner_id = params.owner_id
		end

		if params.type == "private_photos"
			perm.private_photos_requested = true
		elsif params.type == "profile"
			perm.profile_requested = true
		end

		if response = perm.save
			if perm.try(:permitted).try(:is_active)
				if perm.permitted.notification_settings["on_other"]["browser"]
					# PITER_NOTIFY_BROWSER
					# poinformuj permitted o tym ze ktos go poprosił o odblokowanie
				end
			else
				if perm.permitted.notification_settings["on_other"]["email"]
					AccessPermissionMailer.user_requested_unlock(perm).deliver_later
				end
			end
		end

		response
	end
end unless RUBY_ENGINE == 'opal'