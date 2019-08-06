class ProfileGalleryDesktop < Hyperloop::Router::Component

	param user: {}
	param photos_size: nil
	# param is_size_loading: true

	state gallery_opened: false
	state gallery_photo_uri: nil
	state verification_photo_uri: nil
	state errors: {}

	state selected_photo_index: 0
	state gallery_step: 0
	state normal_photo_loader: false
	state verification_photo_loader: false

	state photo_id_for_deletion: nil
	state photo_id_on_top: nil
	state deletion_timeout: nil
	state photos_size: nil
	state confirm_deletion_verification: nil
	state confirm_on_top_verification: nil
	state photos_loaded: {}

	state verification_photo_preview_shown: false

	state all_photos_has_been_loaded: false

	before_mount do
		mutate.all_photos_has_been_loaded false
		mutate.normal_photo_loader false
		mutate.verification_photo_loader false
		mutate.photos_loaded {}
		GalleryStore.toggle_open false
		# photos_scope = Photo.where_user(params.user.try(:id)).order_by_privacy
		mutate.photos_size params.photos_size if params.photos_size.present?
	end

	before_receive_props do |new_props|
		if new_props[:photos_size] && new_props[:photos_size] != state.photos_size
			mutate.photos_size new_props[:photos_size]
		end
	end

	def private_photos_permitted
		private_photos_permitted_is_loaded && AccessPermission.where_owner(params.user.try(:id)).where_permitted(CurrentUserStore.current_user_id).profile_granted.private_photos_granted.first.present?
	end

	def private_photos_permitted_is_loaded
		AccessPermission.where_owner(params.user.try(:id)).where_permitted(CurrentUserStore.current_user_id).profile_granted.private_photos_granted.first.loaded?
	end

	def render
		div(class: "profile-gallery-wrapper-desktop") do

			photos_scope = Photo.where_user(params.user.try(:id)).order_by_privacy

			if (photos_scope.present? && photos_scope.loaded? && state.photos_size.try(:>=, 0))
				all_photos_loaded?(photos_scope)
			end

			GallerySlider(
				user: params.user,
				photos_size: state.photos_size,
				selected_photo_index: state.selected_photo_index,
				can_edit_profile: can_edit_profile,
				private_photos_permitted: private_photos_permitted,
				onDelete: proc { |index| delete_current_photo(index) },
				onModeChange: proc { |photo| update_photo_privacy(photo) },
				onPhotoChange: proc { |index| update_photo_index(index) }
			)

			# full size verificaion photo container
			if should_see_full_verification_photo
				div(class: "verification-photo-container") do
					div(class: "verification-photo-container-inner") do
						img(class: "img-fit", src: params.user.try(:verification_photo_url))
						i(class: "ero-checkmark watermark")
					end
					if can_remove_verification_photo
						div(class: "action-buttons") do
							button(class: "btn btn photo-action-button icon-only btn-small-dark mr-1") do
								i(class: "ero-trash f-s-18")
							end.on :click do |e|
								e.prevent_default
								e.stop_propagation
								show_confirm_deletion_verification
							end
						end
						div(class: "confirm-deletion #{'on-top' if state.confirm_on_top_verification} #{'active' if state.confirm_deletion_verification}") do
							button(class: "btn icon-only btn-container text-secondary white-border white-bg js-propagate") do
								i(class: "ero-trash f-s-24 text-secondary text-center js-propagate")
							end.on :click do |e|
								e.stop_propagation
								e.prevent_default
								delete_vertification_photo
							end
							span(class: "text-white f-s-18 mt-2") {'Usuń zdjęcie'}
						end
					end
					if waiting_for_verification
						div(class: "waiting_for_verification") do
							div(class: "d-flex flex-column align-items-center justify-content-center", "data-tip": "", "data-for": "verification-sent") do
								i(class: "ero-checkmark")
								div(class: "info") {'Zdjęcie wysłane'}
							end
							ReactTooltip("id": "verification-sent", class: 'customeTheme', "place": "bottom", "effect": "solid") do
								div { "Oczekuje" }
								div { "na moderację" }
							end
						end
					end

				end.on :click do
					mutate.verification_photo_preview_shown false
				end
			end

			div(class: "profile-photos-bar streach-me") do
				div(class: "patch")

				div(class: "d-flex flex-column flex-md-row") do

					# place for adding photo
					if its_my_profile
						BlockUi(tag: "div", blocking: state.normal_photo_loader, class: "d-flex") do

							ImageUpload(
								input_id: "gallery-photo",
								fileChanged: proc { |photo_uri| gallery_photo_file_changed(photo_uri) },
								can_upload_photo: true
							) do
								a(class: "add-photo no-underline-i") do
									i(class: "ero-camera f-s-30 text-white")
									div(class: "f-s-12 text-white mt-1") {'Dodaj zdjęcia'}
								end
							end
						end
					end

					# place for verification photo thumb
					if can_see_verification_photo

						# BlockUi(tag: "div", blocking: state.verification_photo_loader, class: "d-flex will-load #{'not-loaded' if !params.user.try(:verification_photo_updated_at).try(:loaded?) || (params.user.try(:verification_photo_updated_at).present? && !is_photo_loaded('verification'))}" ) do

						BlockUi(tag: "div", blocking: state.verification_photo_loader, class: "d-flex will-load #{'not-loaded' if !state.all_photos_has_been_loaded}" ) do
							# verification photo
							ImageUpload(
								input_id: "verification-photo",
								fileChanged: proc { |photo_uri| verification_photo_file_changed(photo_uri) },
								can_upload_photo: can_upload_verification_photo,
								showVerificationPhoto: proc { |var| show_verification_photo(var) }
							) do
								a(id: "js-verification-image", class: "verification no-underline-i") do

									if params.user.try(:verification_photo_url) && params.user.try(:is_verified) && !params.user.try(:rejection_message)
										i(class: 'ero-checkmark icon full-bg is-verified')
									else
										div(class: "verification-text-wrapper") do
											div(class: "verification-text text-center") do
												render_verification_status
											end
										end
									end

									if params.user.try(:verification_photo_updated_at)
										img(class: "verification-img", onLoad: proc { mutate.photos_loaded['verification'] = true }, src: params.user.verification_photo_url('rect_160'))
									end

								end
							end
						end
					end

					div(ref: "photosContainer", class: "photos will-load #{'not-loaded' if !(state.all_photos_has_been_loaded && (params.user.present? && photos_scope.present? && photos_scope.loaded? && state.photos_size.try(:>=, 0))) }") do
						div(ref: 'innerPhotosContainer', class: "photos-inner #{!its_my_profile ? (params.user.try(:is_verified) ? 'for-five' : 'for-six') : 'for-four'}" ) do

							if state.photos_size == 0
								div(class: "photo private-grouped") do
									div(class: "d-flex flex-column align-items-center") do
										i(class: "fa fa-picture-o")
										span(class: "text-white mt-1 text-regular") {'Brak zdjęć'}
									end
								end
							end

							photos_scope.group_by{ |p| !!p.is_private }.each do |is_private, photos|

								if is_private == false || (can_see_blurred_is_loaded && can_see_blurred && can_see_private_gallery_is_loaded && can_see_private_gallery)

									photos.each_with_index do |photo, index|
										div(class: "photo") do
											if can_edit_profile
												div(class: "photo-action-buttons") do
													button("data-tip": "", "data-for": "small-gallery-avatar-#{photo.id.to_s}", class: "btn btn photo-action-button icon-only btn-small-dark mr-1") do
														i(class: "ero-user f-s-18")
													end.on :click do |e|
														set_as_avatar photo
													end
													ReactTooltip("id": "small-gallery-avatar-#{photo.id.to_s}", class: 'customeTheme', "place": "bottom", "effect": "solid") do
														div { "Ustaw jako" }
														div { "avatar" }
													end
													button("data-tip": "", "data-for": "small-gallery-lock-#{photo.id.to_s}", class: "btn btn photo-action-button gallery-lock #{"active" if photo.try(:is_private).try(:loaded?) && photo.is_private } icon-only btn-small-dark mr-1") do
														i(class: "ero-locker f-s-20")
													end.on(:click) do |e|
														e.stop_propagation
														e.prevent_default
														update_photo_privacy photo, e
													end
													ReactTooltip("id": "small-gallery-lock-#{photo.id.to_s}", class: 'customeTheme', "place": "bottom", "effect": "solid") do
														div { "Ustaw jako" }
														div { photo.is_private ? "Publiczne" : "Prywatne" }
													end
													button("data-tip": "", "data-for": "small-gallery-delete-#{photo.id.to_s}", class: "btn btn photo-action-button icon-only btn-small-dark mr-1") do
														i(class: "ero-trash f-s-18")
													end.on :click do |e|
														e.stop_propagation
														e.prevent_default
														confirm_deletion photo.id
													end
													ReactTooltip("id": "small-gallery-delete-#{photo.id.to_s}", class: 'customeTheme', "place": "bottom", "effect": "solid") do
														span { "Usuń" }
													end
												end
											end

											if photo.try(:is_private).try(:loaded?) && !can_edit_profile && photo.is_private && !private_photos_permitted
												i(class: "ero-locker photo-locked-icon")
											end

											div(class: "confirm-deletion #{'active' if state.photo_id_for_deletion == photo.id} #{'on-top' if state.photo_id_on_top == photo.id}") do
												button(class: "btn icon-only btn-container text-secondary white-border white-bg js-propagate") do
													i(class: "ero-trash f-s-22 text-white text-center js-propagate text-secondary")
												end.on :click do |e|
													e.stop_propagation
													e.prevent_default
													delete_current_photo photo.id, photos_scope, e
												end
												span(class: "text-white f-s-14 mt-2") {'Usuń zdjęcie'}
											end

											img(class: "img-fluid", onLoad: proc { mutate.photos_loaded[photo.id.to_s] = true }, src: photo_url(photo)).on :click do
												open_photo_in_gallery photo.id, photos_scope
											end

										end
									end

								elsif can_see_blurred_is_loaded && !can_see_blurred && can_see_private_gallery_is_loaded && can_see_private_gallery
									div(class: "photo private-grouped") do
										div(class: "private-grouped-inner") do
											i(class: "ero-locker mb-2")
											span(class: "text-white text-regular f-s-12") do
												Pluralized({count: photos.size, one: 'prywatne zdjęcie', few: 'prywatne zdjęcia', many: 'prywatnych zdjęć', ohter: 'prywatnych zdjęć'})
											end
										end
									end.on :click do
										open_photo_in_gallery nil, photos_scope, true
									end

								end

							end
						end

						button(class: "btn icon-only btn-small-dark left #{'disabled' if state.gallery_step == 0 || state.photos_size == 0 || !state.all_photos_has_been_loaded }", type: "button") do
							i(class: "ero-chevron-left f-s-13")
						end.on :click do |e|
							e.prevent_default
							e.stop_propagation
							move_gallery_left(e)
						end

						button(class: "btn icon-only btn-small-dark right #{'disabled' if (state.gallery_step == max_gallery_steps || state.photos_size == 0 ||  !state.all_photos_has_been_loaded )}", type: "button") do
							i(class: "ero-chevron-right f-s-13")
						end.on :click do |e|
							e.prevent_default
							e.stop_propagation
							move_gallery_right(e)
						end
					end.on :click do |e|
						GalleryStore.toggle_open true
					end

					div(class: "photos-loading  #{'d-none' if (state.all_photos_has_been_loaded && (params.user.present? && photos_scope.present? && photos_scope.loaded? && state.photos_size.try(:>=, 0))) }") do
						div(class: 'dots-container pt-0') do
						  div(class: 'animated-dots ') do
						    span {'.'}
						    span {'.'}
						    span {'.'}
						  end
						end
					end

				end
			end

			if can_edit_profile && CurrentUserStore.current_user.present? && !CurrentUserStore.current_user.try(:is_admin) && params.user.try(:rejection_message) && params.user.try(:rejection_message).loaded?
				div(class: "alert-section") do
					div(class: "d-flex align-center") do
						img(src:'/assets/warning-white-small.png')
						div(class: "alert-text") do
							strong() { "Weryfikacja konta się nie powiodła!" }
							div(class: "text-book f-s-12") { "Powód: " + params.user.try(:rejection_message).try(:to_s) }
						end
					end

					button(class: "btn btn-secondary mt-3 mb-3") do
						span(class: "f-s-12") { 'Wstaw nowe zdjęcie weryfikacyjne' }
					end.on(:click) do
						`document.getElementById('js-verification-image').click()`
					end
				end

			end
		end
	end

	def is_photo_loaded attr
		state.photos_loaded[attr]

		# if can_see_verification_photo
		# 	params.photos_size.present? && state.photos_loaded.keys.select{ |k| !!state.photos_loaded[k] }.size == params.photos_size + 1
		# else
		# 	params.photos_size.present? && state.photos_loaded.keys.select{ |k| !!state.photos_loaded[k] }.size == params.photos_size
		# end
	end

	def all_photos_loaded? photos_scope
		if !state.all_photos_has_been_loaded

			photos_load_indicators = []
			photos_scope.group_by{ |p| !!p.is_private }.each do |is_private, photos|
				photos.each do |photo|
					if is_private == false || (can_see_blurred_is_loaded && can_see_blurred && can_see_private_gallery_is_loaded && can_see_private_gallery)
						photos_load_indicators.push is_photo_loaded(photo.try(:id).to_s)
					end
				end
			end

			# photos_load_indicators = photos.map do |photo|
			# 	is_photo_loaded photo.try(:id).to_s
			# end

			all_photos_loaded = photos_load_indicators.all? { |val| val == true }

			# puts "photos_load_indicators: #{photos_load_indicators}, all_photos_loaded: #{all_photos_loaded}"


			if all_photos_loaded && (!can_see_verification_photo || !params.user.try(:verification_photo_updated_at) || is_photo_loaded('verification'))
				mutate.all_photos_has_been_loaded true
			end
		end
	end

	def set_as_avatar photo
    ModalsService.open_modal('ProfileAvatarModal', {user: CurrentUserStore.current_user, photo_id: photo.id} )
	end

	def confirm_deletion id
		mutate.photo_id_for_deletion id
		mutate.photo_id_on_top id

		%x|
			var clickCallback = function(event) {
				if(!event.target.classList.contains('js-propagate')){
					event.stopPropagation()
				}

				event.preventDefault()
				#{cancel_deletion_confirmation}
				document.body.removeEventListener('click', clickCallback)
			}

			document.body.addEventListener('click', clickCallback)
		|
	end

	def cancel_deletion_confirmation
		mutate.photo_id_for_deletion nil
		after(0.41) do
			mutate.photo_id_on_top nil
		end
	end

	def show_confirm_deletion_verification
		mutate.confirm_deletion_verification true
		mutate.confirm_on_top_verification true

		%x|
			var clickCallbackVerification = function(event) {
				if(!event.target.classList.contains('js-propagate')){
					event.stopPropagation()
				}

				event.preventDefault()
				#{confirm_deletion_cancel_verification}
				document.body.removeEventListener('click', clickCallbackVerification)
			}

			document.body.addEventListener('click', clickCallbackVerification)
		|

		if state.cancel_confirm_timeout_verification
			state.cancel_confirm_timeout_verification.abort
		end
		mutate.cancel_confirm_timeout_verification(after(4) do
			confirm_deletion_cancel
			`document.body.removeEventListener('click', clickCallbackVerification)`
		end)
	end

	def confirm_deletion_cancel
		mutate.confirm_deletion_index nil
		after(0.41) do
			mutate.confirm_on_top_index nil
		end
	end

	def confirm_deletion_cancel_verification
		mutate.confirm_deletion_verification nil
		after(0.41) do
			mutate.confirm_on_top_verification nil
		end
	end

	def photo_url photo
		photo.url + '&u=' + (CurrentUserStore.current_user_id.try(:to_s) || '') + "#{private_photos_permitted ? '1' : '0'}"
	end

	# def mocked_image_upload
	# 	span() do
	# 		div(class: "d-flex") do
	# 			label(class: 'mb-0 ea-flex-1') do
	# 				a(class: "add-photo no-underline-i") do
	# 					i(class: "ero-camera f-s-30 text-white")
	# 					span(class: 'first-person mocked-bit-wide-short mt-2')
	# 				end
	# 			end
	# 			label(class: 'mb-0 ea-flex-1') do
	# 				a(id: "js-verification-image", class: "verification no-underline-i") do
	# 					div(class: "verification-text-wrapper") do
	# 						div(class: "verification-text text-center") do
	# 							i(class: "ero-sad-face f-s-30 text-white")
  #               span(class: 'first-person mocked-bit-wide-short d-block mt-2')
	# 						end
	# 					end
	# 				end
	# 			end
	# 		end
	# 	end
	# end

	def show_verification_photo var
		mutate.verification_photo_preview_shown true
		GalleryStore.toggle_open true
	end

	def can_upload_verification_photo
		its_my_profile && !params.user.try(:verification_photo_updated_at) && params.user.try(:is_verified) == false
	end

	def can_edit_profile
		its_my_profile || CurrentUserStore.current_user.try(:is_admin)
	end

	def its_my_profile
		CurrentUserStore.current_user_id == params.user.try(:id)
	end

	def can_see_verification_photo
		its_my_profile || params.user.try(:is_verified)
	end

	def can_remove_verification_photo
		its_my_profile && !params.user.try(:is_verified)
	end

	def waiting_for_verification
		!params.user.try(:is_verified)
	end

	def should_see_full_verification_photo
		can_see_verification_photo && state.verification_photo_preview_shown && params.user.try(:verification_photo_updated_at)
	end

	def can_see_blurred
		(params.user.try(:privacy_settings).try(:loaded?) && params.user.try(:privacy_settings).try(:[], 'show_blurred') == true) || can_edit_profile || private_photos_permitted
	end

	def can_see_blurred_is_loaded
		params.user.try(:privacy_settings).try(:loaded?) && private_photos_permitted_is_loaded
	end

	def can_see_private_gallery
		(params.user.try(:privacy_settings).try(:loaded?) && params.user.try(:privacy_settings).try(:[], 'show_gallery') == true) || can_edit_profile || private_photos_permitted
	end

	def can_see_private_gallery_is_loaded
		params.user.try(:privacy_settings).try(:loaded?) && private_photos_permitted_is_loaded
	end

	def open_photo_in_gallery id, photos_scope, private=false
		if private
			index = photos_scope.select{ |ps| !ps.is_private }.size
			# puts "SELECTING INDEX: #{index}"
			if state.selected_photo_index != index
				# puts "WILL DO: #{index}"
				mutate.selected_photo_index index
			end
		else
			index = photos_scope.index{ |p| p.id == id }
			if state.selected_photo_index != index
				mutate.selected_photo_index index
			end
		end

		mutate.verification_photo_preview_shown false
	end

	def update_photo_index index
		if state.selected_photo_index != index
			mutate.selected_photo_index index
		end

		mutate.verification_photo_preview_shown false
	end

	def update_photo_privacy photo, e = nil
		if e
			e.stop_propagation
		end

		next_mode = (photo.is_private ? "publiczne" : "prywatne")
		UpdatePhotoMode.run({
			photo_id: photo.id
		})
		.fail do |e|
			handle_errors(e)
		end
	end

	def delete_current_photo id, photos_scope, e = nil
		index = photos_scope.index{ |p| p.id == id }
		if e
			e.stop_propagation
		end
		DeleteUserPhoto.run({
			photo_id: id
		})
		.then do |response|
			mutate.photos_size(state.photos_size - 1)
			react_to_photo_deletion(index, state.photos_size)
		end
		.fail do |e|
			handle_errors(e)
		end
	end

	def delete_vertification_photo e=nil
		if e
			e.stop_propagation
		end
		DeleteVerificationPhoto.run({
			user_id: params.user.try(:id)
		})
		.then do |response|
			confirm_deletion_cancel_verification
			`toast.dismiss(); toast.success('Zdjęcie weryfikacyjne zostało usunięte.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
		end
		.fail do |e|
			# mutate.blocking(false)
			handle_errors(e)
		end
	end

	def react_to_photo_deletion index, size = state.photos_size
		photos_amount = size

		if (state.gallery_step || 0) > max_gallery_steps && (state.gallery_step || 0) > 0
			mutate.gallery_step (state.gallery_step - 1)

			if !refs['photosContainer'].nil?
				photos_container_width = refs['photosContainer'].clientWidth
			else
				photos_container_width = 0
			end
			translate_photos_inner -photos_container_width * (state.gallery_step)
		end

		# switch to near photo
		last_index = photos_amount - 1
		if index > last_index
			mutate.selected_photo_index(last_index)
		end
	end


	def handle_errors(e)
		`toast.error('Coś poszło nie tak.')`
		if e.is_a?(ArgumentError)
			mutate.errors e
		elsif e.is_a?(Hyperloop::Operation::ValidationException)
			mutate.errors e.errors.message
		end
	end

	def max_gallery_steps
		available_photos = state.photos_size || 0
		if its_my_profile
			result = (available_photos/4.to_f).ceil - 1
		elsif params.user.try(:is_verified)
			result = (available_photos/5.to_f).ceil - 1
		else
			result = (available_photos/6.to_f).ceil - 1
		end
		if result < 0
			result = 0
		end
		result
	end

	def move_gallery_left e
		e.stop_propagation
		if !refs['photosContainer'].nil?
			photos_container_width = refs['photosContainer'].clientWidth
		else
			photos_container_width = 0
		end

		if state.gallery_step == 0
			translate_photos_inner 0

		elsif (state.gallery_step || 0) > 0 && state.gallery_step < max_gallery_steps + 1
			mutate.gallery_step (state.gallery_step - 1)
			translate_photos_inner -photos_container_width * state.gallery_step
		end

	end

	def move_gallery_right e
		e.stop_propagation
		if !refs['photosContainer'].nil?
			photos_container_width = refs['photosContainer'].clientWidth
		else
			photos_container_width = 0
		end

		if state.gallery_step == 0 && max_gallery_steps != 0
			mutate.gallery_step(state.gallery_step + 1)
			translate_photos_inner -photos_container_width

		elsif (state.gallery_step || 0) > 0 && state.gallery_step < max_gallery_steps
			mutate.gallery_step(state.gallery_step + 1)
			translate_photos_inner -photos_container_width * state.gallery_step
		end
	end

	def translate_photos_inner amount
		# Element['.photos-inner'].css(transform: "translateX( #{ amount }px )")
		if !refs['innerPhotosContainer'].nil?
			refs['innerPhotosContainer'].style['transform'] = "translateX( #{ amount }px )"
		end
	end

	def render_verification_status
		if params.user.try(:verification_photo_updated_at).loaded? && params.user.try(:is_verified).loaded? && params.user.try(:rejection_message).loaded?
			if !params.user.try(:verification_photo_updated_at) && !params.user.try(:is_verified)
				i(class: 'ero-checkmark icon')
				div(class: "f-s-12 text-white mt-1") {'Zweryfikuj się'}
			elsif params.user.try(:verification_photo_updated_at) && !params.user.try(:is_verified) && !params.user.try(:rejection_message)
				i(class: 'ero-checkmark icon')
				div(class: "f-s-12 text-white mt-1") {'Zdjęcie wysłane'}
			elsif params.user.try(:verification_photo_updated_at) && !params.user.try(:is_verified) && params.user.try(:rejection_message)
				i(class: "ero-sad-face f-s-30 text-white")
				div(class: "f-s-12 text-white mt-1") {'Weryfikacja się nie powiodła'}
			end
		end
	end

	def save_gallery_photo
		after(0) do
			mutate.normal_photo_loader true
			SaveUserPhoto.run({
				user_id: params.user.try(:id),
				photo_uri: state.gallery_photo_uri
			})
			.then do |data|
				# LUKAS - Po wgraniu zdjęcia nie animujemy karuzeli
				# mutate.photos_size(state.photos_size + 1)
				# mutate.selected_photo_index(state.photos_size - 1)
				mutate.normal_photo_loader false
			end
			.fail do |e|
				mutate.normal_photo_loader false
				`toast.error('Przepraszamy! Coś poszło nie tak.')`
				if e.class.name.to_s == 'ArgumentError'
					errors = JSON.parse(e.message.gsub('=>', ':'))
					errors.each do |k, v|
						errors[k] = v.join('; ')
					end
					mutate.errors errors
				elsif e.is_a?(Hyperloop::Operation::ValidationException)
					mutate.errors e.errors.message
				end
				{}
			end
		end
	end

	def gallery_photo_file_changed data
		mutate.gallery_photo_uri data;
		save_gallery_photo
	end

	def save_verification_photo
		after(0) do
			mutate.verification_photo_loader true
			SaveUserVerificationPhoto.run({
				user_id: params.user.try(:id),
				verification_photo_uri: state.verification_photo_uri,
				acting_user: CurrentUserStore.current_user
			})
			.then do |data|
				mutate.verification_photo_loader false
				`toast.dismiss(); toast.success('Twój profil został przekazany do weryfikacji.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
			end
			.fail do |e|
				puts "BLAD #{e}"
				mutate.verification_photo_loader false
				`toast.error('Przepraszamy! Coś poszło nie tak.')`
				if e.class.name.to_s == 'ArgumentError'
					errors = JSON.parse(e.message.gsub('=>', ':'))
					errors.each do |k, v|
						errors[k] = v.join('; ')
					end
					mutate.errors errors
				elsif e.is_a?(Hyperloop::Operation::ValidationException)
					mutate.errors e.errors.message
				end
				{}
			end
		end
	end

	def verification_photo_file_changed data
		mutate.verification_photo_uri data;
		save_verification_photo
	end
end