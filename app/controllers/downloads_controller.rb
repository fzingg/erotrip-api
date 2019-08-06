class DownloadsController < ApplicationController

	def serve_user_avatar
		user = User.find_by_id(params[:user_id])

		if user.present?
			if params[:version] && params[:version] == "blurred" # saves 1 query
				serve user.try(:avatar_uploader).try(:blurred).try(:path)
			elsif !user.is_private? || can_access_profile(user) || can_access_hotline_profile(user, params[:hotline_id]) || can_access_trip_profile(user, params[:trip_id])
				serve user.try(:avatar_uploader).try(:rect_160).try(:path)
			else
				serve user.try(:avatar_uploader).try(:blurred).try(:path)
			end
		else
			serve nil
		end
	end

	def serve_user_group_avatar
		user_group = UserGroup.find_by_id(params[:user_group_id])

		if user_group.present? && user_group.user.present?
			if params[:version] && params[:version] == "blurred"
				serve user_group.user.try(:avatar_uploader).try(:blurred).try(:path)
			elsif (user_group.is_public && !user_groupkl.user.is_private?) || can_access_profile(user_group.user)
				serve user_group.user.try(:avatar_uploader).try(:rect_160).try(:path)
			else
				serve user_group.user.try(:avatar_uploader).try(:blurred).try(:path)
			end
		else
			serve nil
		end
	end

	def serve_room_user_avatar
		room = Room.find_by_id(params[:room_id])

		if room.hotline_id.present?
			user = User.find_by_id(params[:user_id])

			if user.present?
				if params[:version] && params[:version] == "blurred" # saves 1 query
					serve user.try(:avatar_uploader).try(:blurred).try(:path)
				elsif (!user.is_private? && !(user.id == room.hotline.user_id && room.hotline.is_anonymous)) || can_access_profile(user) || can_access_hotline_profile(user, room.hotline_id)
					serve user.try(:avatar_uploader).try(:rect_160).try(:path)
				else
					serve user.try(:avatar_uploader).try(:blurred).try(:path)
				end
			else
				serve nil
			end

		elsif room.trip_id.present?
			user = User.find_by_id(params[:user_id])

			if user.present?
				if params[:version] && params[:version] == "blurred" # saves 1 query
					serve user.try(:avatar_uploader).try(:blurred).try(:path)
				elsif (!user.is_private? && !(user.id == room.trip.user_id && room.trip.is_anonymous)) || can_access_profile(user) || can_access_trip_profile(user, room.trip_id)
					serve user.try(:avatar_uploader).try(:rect_160).try(:path)
				else
					serve user.try(:avatar_uploader).try(:blurred).try(:path)
				end
			else
				serve nil
			end

		else
			serve_user_avatar
		end

	end

	def serve_trip_avatar
		trip = Trip.find_by_id(params[:trip_id])

		if trip.present? && trip.user.present?
			if params[:version] && params[:version] == "blurred" # saves 1 query
				serve trip.user.try(:avatar_uploader).try(:blurred).try(:path)
			elsif (!trip.is_anonymous && !trip.user.is_private?) || can_access_profile(trip.user) || can_access_trip_profile(trip.user, trip.id)
				serve trip.user.try(:avatar_uploader).try(:rect_160).try(:path)
			else
				serve trip.user.try(:avatar_uploader).try(:blurred).try(:path)
			end
		else
			serve nil
		end
	end

	def serve_hotline_avatar
		hotline = Hotline.find_by_id(params[:hotline_id])

		if hotline.present? && hotline.user.present?
			if params[:version] && params[:version] == "blurred" # saves 1 query
				serve hotline.user.try(:avatar_uploader).try(:blurred).try(:path)
			elsif (!hotline.is_anonymous && !hotline.user.is_private?) || can_access_profile(hotline.user) || can_access_hotline_profile(hotline.user, hotline.id)
				serve hotline.user.try(:avatar_uploader).try(:rect_160).try(:path)
			else
				serve hotline.user.try(:avatar_uploader).try(:blurred).try(:path)
			end
		else
			serve nil
		end
	end

	def serve_my_avatar
		if acting_user.present?
			serve acting_user.try(:avatar_uploader).try(:rect_160).try(:path)
		else
			serve nil
		end
	end

	def serve_user_verification_photo
		user = User.find_by_id(params[:user_id])

		if params[:version].present?
			serve user.try(:verification_photo_uploader).try(params[:version]).try(:path)
		else
			serve user.try(:verification_photo_uploader).try(:full).try(:path)
		end
		# if user.present? && owns_profile(user)
		# else
		# 	serve nil
		# end
	end

	def serve_message_photo
		message = Message.find_by_id(params[:message_id])
		user = message.try(:user)
		# User.find_by_id(params[:user_id])

		if user && message
			if params[:version].present?
				serve message.try(:file_uploader).try(params[:version]).try(:path)
			else
				serve message.try(:file_uploader).try(:full).try(:path)
			end
		else
			serve nil
		end
	end

	def serve_photo
		photo = Photo.find_by_id(params[:photo_id])
		user = photo.try(:user)
		# User.find_by_id(params[:user_id])

		if user && photo && (!user.is_private? || can_access_profile(user))
			# acting user can access profile
			if params[:version] && (params[:version] == "blurred" || params[:version] == "blurred_full" && photo.user.privacy_settings['show_blurred'] == true)#save query
				serve photo.try(:file_uploader).try(params[:version]).try(:path)

			# if params[:version] && params[:version] == "blurred" #save query
			# 	serve photo.try(:file_uploader).try(:blurred).try(:path)

			elsif photo.is_private?
				if can_access_private_photos(user)
					if params[:version].present?
						serve photo.try(:file_uploader).try(params[:version]).try(:path)
					else
						serve photo.try(:file_uploader).try(:rect_150).try(:path)
					end
				elsif !photo.user.privacy_settings['show_blurred']
					serve nil
				else
					serve photo.try(:file_uploader).try(:blurred).try(:path)
				end
			elsif !photo.is_private?
				if params[:version].present?
					serve photo.try(:file_uploader).try(params[:version]).try(:path)
				else
					serve photo.try(:file_uploader).try(:rect_150).try(:path)
				end
			end
		else
			serve nil
		end
	end


	def serve_full_photo
		photo = Photo.find_by_id(params[:photo_id])
		user = photo.try(:user)
		# User.find_by_id(params[:user_id])

		if user && photo && (!user.is_private? || can_access_profile(user))
			# acting user can access profile
			if params[:version] && (params[:version] == "blurred" || params[:version] == "blurred_full") && photo.user.privacy_settings['show_blurred'] == true #save query
				serve photo.try(:file_uploader).try(params[:version]).try(:path)

			# if params[:version] && params[:version] == "blurred" #save query
			# 	serve photo.try(:file_uploader).try(:blurred).try(:path)

			elsif photo.is_private?
				if can_access_private_photos(user)
					if params[:version].present?
						serve photo.try(:file_uploader).try(params[:version]).try(:path)
					else
						serve photo.try(:file_uploader).try(:full).try(:path)
					end
				elsif !photo.user.privacy_settings['show_blurred']
					serve nil
				else
					serve photo.try(:file_uploader).try(:blurred_full).try(:path)
				end
			elsif !photo.is_private?
				if params[:version].present?
					serve photo.try(:file_uploader).try(params[:version]).try(:path)
				else
					serve photo.try(:file_uploader).try(:full).try(:path)
				end
			end
		else
			serve nil
		end
	end

	def owns_profile user
		acting_user.try(:id) == user.try(:id) || acting_user.try(:is_admin?)
	end

	def can_access_profile user
		acting_user.present? && (owns_profile(user) || AccessPermission.where_owner(user.id).where_permitted(acting_user.id).profile_granted.first.present?)
	end

	def can_access_hotline_profile user, hotline_id
		if hotline_id.present? && hotline_id.to_i > 0
			HotlineAccessPermission.where(hotline_id: hotline_id, owner_id: user.id, permitted_id: acting_user.try(:id), is_permitted: true).count > 0
		else
			false
		end
	end

	def can_access_trip_profile user, trip_id
		if trip_id.present? && trip_id.to_i > 0
			TripAccessPermission.where(trip_id: trip_id, owner_id: user.id, permitted_id: acting_user.try(:id), is_permitted: true).count > 0
		else
			false
		end
	end

	def can_access_private_photos user
		acting_user.present? && (owns_profile(user) || AccessPermission.where_owner(user.id).where_permitted(acting_user.id).private_photos_granted.first.present?)
	end

	def serve path
		if path.blank? || !File.file?(path)
			path = avatar_mock
		end
		send_file path, :type => 'image/jpeg', :disposition => 'inline'
	end

	def avatar_mock
		Rails.root.join('restricted', 'user-blank.png')
	end
end