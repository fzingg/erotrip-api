class GetProfile < Hyperloop::ControllerOp; end
class GetProfile < Hyperloop::ControllerOp
	outbound :response
	param :user_id, nils: false

	def owned_by_acting_user user
		if acting_user && (acting_user.is_admin? || acting_user.id == user.id)
			true
		else
			false
		end
	end

	step do
		user = User.find(params.user_id)
	end
	# Create visit if acting_user is not profile user, if acting_user allows to show visits, is not admin and is not annonymous
	step do |user|
		if acting_user && user.id != acting_user.id && acting_user.privacy_settings["show_visits"] && !acting_user.is_admin? && !acting_user.is_private?
			visit = Visit.where(visitor_id: acting_user.id, visitee_id: user.id).first_or_initialize do |v|
				v.visitor_id = acting_user.id
				v.visitee_id = user.id
			end

			notify = false

			if visit.updated_at.blank? || Time.parse(visit.updated_at.to_s) < (Time.now - 15.minutes)
				notify = true
				visit.updated_at = Time.now
			end

			visit.save

			if notify
				if visit.try(:visitee).try(:is_active)
					if visit.visitee.notification_settings["on_guest"]["browser"]
						puts "\n\nSHOULD NOTIFY VIA BROWSER\n\n"
						# PITER_NOTIFY_BROWSER
						# tutaj poinformuj visitee o tym ze ktos go odwiedził (musi byc nowe lub 15 minut od ostatniej wizyty)
					end
				else
					if visit.visitee.notification_settings["on_guest"]["email"]
						puts "\n\nSHOULD NOTIFY VIA EMAIL\n\n"
						VisitMailer.user_visited_your_profile(visit).deliver_later
					end
				end
			end
		end

		user
	end

	step do |user|
		if user.is_private? && (!owned_by_acting_user(user) && !AccessPermission.profile_granted.where(permitted_id: acting_user.id, owner_id: user.id).first.present?)
			raise Hyperloop::AccessViolation
		else
			user
		end
	end
	# Shouldn't all attrs except id be filtered out?
	step do |user|
		user[:verification_photo_uploader] = nil
		user[:avatar_uploader] = nil
		params.response = user
	end
end