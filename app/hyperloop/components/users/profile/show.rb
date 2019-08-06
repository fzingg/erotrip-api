class Profile < Hyperloop::Router::Component

	state blocking: false
	state gallery_opened: false
	state errors: {}
	state user: nil
	state loaded: false
	state active_hotline: nil
	state active_trip: nil
	state show_settings: false

	before_receive_props do |next_props|
		if state.user && next_props[:match].params && next_props[:match].params[:user_id].to_s != state.user.try(:id).to_s
			get_profile next_props[:match].params[:user_id]
		end
		after(0) do
			if location.query.present? && location.query['hot'].present?
				mutate.active_hotline Hotline.find(location.query['hot'].to_i)
			else
				mutate.active_hotline nil
			end

			if location.query.present? && location.query['trip'].present?
				mutate.active_trip Trip.find(location.query['trip'].to_i)
			else
				mutate.active_trip nil
			end
		end
	end

	before_mount do
		if location.query.present? && location.query['hot'].present?
			mutate.active_hotline Hotline.find(location.query['hot'].to_i)
		else
			mutate.active_hotline nil
		end

		if location.query.present? && location.query['trip'].present?
			mutate.active_trip Trip.find(location.query['trip'].to_i)
		else
			mutate.active_trip nil
		end

		# puts "acting_user_id: #{Hyperloop::Application.acting_user_id}"
		# puts "user to display: #{match.params[:user_id]}"

		get_profile
	end

	# after_mount do
	# end

	def get_profile user_id_override
		# puts "BEFORE GET PROFILE, match.params[:user_id]: #{match.params[:user_id]}"
		GetProfile.run({user_id: (user_id_override || match.params[:user_id])})
		.then do |response|
			# puts "GOT PROFILE #{response.inspect}"
			# if React::IsomorphicHelpers.on_opal_client?
			# 	after(0) {
			# 		mutate.user User.find(response[:id])
			# 		mutate.loaded true
			# 	}
			# else
				mutate.user User.find(response[:id])
				mutate.loaded true
			# end
		end
		.fail do |e|
			# puts "ERROR GETTING PROFILE #{e.inspect}"
			history.replace('/profile-not-found')
		end
	end

	def owned_by_acting_user resource
		if CurrentUserStore.current_user && (CurrentUserStore.current_user.try(:is_admin) || CurrentUserStore.current_user_id == resource.try(:id))
			true
		else
			false
		end
	end

	def is_desktop_or_tablet?
		if React::IsomorphicHelpers.on_opal_client?
			`window.innerWidth > 768`
		end
	end

	def get_photos_size
		if state.user.present?
			if state.user.try(:privacy_settings).try(:[], 'show_blurred') == true || can_edit_profile || AccessPermission.where_owner(state.user.try(:id)).where_permitted(CurrentUserStore.current_user_id).profile_granted.private_photos_granted.first.present?
				# puts "INSIDE 1"
				result = Photo.where_user(state.user.try(:id)).count
			else
				# puts "INSIDE 2 #{state.user.photos.only_public.count}"
				result = (Photo.where_user(state.user.try(:id)).only_public.count || 0)
				if Photo.where_user(state.user.try(:id)).only_private.count.try(:>, 0)
					result += 1
				end
			end
		else
			# puts "INSIDE 3"
			result = 0
		end
		# puts "USER PHOTOS SIZE #{result}"
		result
	end

	def is_size_loading
		if state.user.present?
			if state.user.try(:privacy_settings).try(:[], 'show_blurred') == true || can_edit_profile || AccessPermission.where_owner(state.user.try(:id)).where_permitted(CurrentUserStore.current_user_id).profile_granted.private_photos_granted.first.present?
				result = !Photo.where_user(state.user.try(:id)).count.loaded?
			else
				result = !Photo.where_user(state.user.try(:id)).only_public.count.loaded? || !Photo.where_user(state.user.try(:id)).only_private.count.loaded?
			end
		else
			result = true
		end
		# puts "IS SIZE LOADING? #{result}"
		result
	end

	def can_edit_profile
		CurrentUserStore.current_user.try(:is_admin) || CurrentUserStore.current_user_id == state.user.try(:id)
	end

	def render
		div(class: 'row') do
			div(class: 'col-12 col-xl-9 ml-xl-auto main-content profile') do

				# if is_desktop_or_tablet?
				# 	ProfileInfoBar(user: state.user, hotline: state.active_hotline, trip: state.active_trip, location: location)
				# 	# , onToggleSettings: proc { |state| mutate.show_settings state })
				# 	if (state.user.try(:privacy_settings).present? && state.user.privacy_settings["show_gallery"]) || owned_by_acting_user(state.user)
				# 		ProfileGalleryDesktop(user: state.user, is_size_loading: is_size_loading, photos_size: get_photos_size)
				# 	end
				# else
				# 	if (state.user.try(:privacy_settings).present? && state.user.privacy_settings["show_gallery"]) || owned_by_acting_user(state.user)
				# 		ProfileGalleryMobile(user: state.user, is_size_loading: is_size_loading, photos_size: get_photos_size)
				# 	end
				# 	ProfileInfoBar(user: state.user, hotline: state.active_hotline, trip: state.active_trip, location: location)
				# 	# , onToggleSettings: proc { |state| mutate.show_settings state })
				# end

				div(class: 'd-block d-md-none') do
					ProfileGalleryMobile(
						user: state.user,
						photos_size: is_size_loading == true ? nil : get_photos_size
					)
				end

				span do
					ProfileInfoBar(current_pathname: location.pathname, user: state.user, hotline: state.active_hotline, trip: state.active_trip)
				end

				div(class: 'd-none d-md-block') do
					ProfileGalleryDesktop(
						user: state.user,
						photos_size: is_size_loading == true ? nil : get_photos_size
					)
				end

				if location.pathname.end_with?('/settings')
					ProfileSettings(user: state.user)
				else
					ProfileDetails(user: state.user)
				end

			end

			div(class: 'col-12 col-xl-9 ml-xl-auto') do
				if CurrentUserStore.current_user.try(:is_admin).try(:loaded?) && CurrentUserStore.current_user.try(:is_admin)

					div(class: "d-flex justify-content-center") do
						button(class: "btn btn-secondary btn-sm-block btn-md mt-4", type: "button") do
							"Rodzaj: " + (state.user.try(:is_admin) ? "Admin" : "User")
						end.on :click do |e|
							toggle_admin_status
						end
					end
				end
			end
		end
	end

	def toggle_admin_status
		if !state.blocking
		SaveUserAdminStatus.run(user_id: state.user.try(:id))
			.then do |response|
				mutate.blocking false
			end
			.fail do |e|
				mutate.blocking false
			end
		end
	end
end