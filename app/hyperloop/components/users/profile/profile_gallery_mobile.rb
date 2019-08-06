class ProfileGalleryMobile < Hyperloop::Router::Component

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

	state blocking: false
	state blockingVerification: false
	state confirm_deletion_index: nil
	state confirm_on_top_index: nil
	state cancel_confirm_timeout: nil
	state photos_size: nil
	state confirm_deletion_verification: nil
	state confirm_on_top_verification: nil

	state show_verification_photo: false
	state photos_loaded: {}

	before_mount do
		mutate.normal_photo_loader false
		mutate.verification_photo_loader false
		mutate.photos_size params.photos_size if params.photos_size.present?
	end

	before_receive_props do |new_props|
		if new_props[:photos_size].present? && new_props[:photos_size] != state.photos_size
			mutate.photos_size new_props[:photos_size]
		end
	end

	def render
		div(class: "profile-gallery-wrapper-mobile") do
			photos_scope = Photo.where_user(params.user.try(:id)).order_by_privacy

			if state.photos_size.try(:>=, 0)
				GallerySlider(
					user: params.user,
					# photos: photos_scope,
					photos_size: state.photos_size,
					selected_photo_index: state.selected_photo_index,
					can_edit_profile: can_edit_profile,
					private_photos_permitted: AccessPermission.where_owner(params.user.try(:id)).where_permitted(CurrentUserStore.current_user_id).profile_granted.private_photos_granted.first,
					onDelete: proc { |index| delete_current_photo(index) },
					onModeChange: proc { |photo| update_photo_mode(photo) },
					onPhotoChange: proc { |index| update_photo_index(index) },
					onClick: proc { |val| open_gallery_mobile_modal(val) },
					show_no_photos: true
				)
			end

			# verificaion photo container
			if should_see_full_verification_photo
				div(class: "verification-photo-container") do
					div(class: "verification-photo-container-inner js-propagate") do
						img(
							class: "img-fit",
							src: params.user.try(:verification_photo_url)
						)
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
					mutate.show_verification_photo false
				end
			end

			if can_edit_profile == true
				BlockUi(tag: "div", blocking: state.normal_photo_loader, class: "block-ui-add-photo") do
					# add photo
					ImageUpload(input_id: "gallery-photo", fileChanged: proc { |photo_uri| gallery_photo_file_changed(photo_uri) }) do
						i(class: "ero-camera f-s-30")
					end
				end
			end

			if can_see_verification_photo
				BlockUi(
					tag: "div",
					blocking: state.verification_photo_loader,
					class: "block-ui-varification-photo will-load #{'not-loaded' if !params.user.try(:verification_photo_updated_at).try(:loaded?) || (params.user.try(:verification_photo_updated_at).present? && !is_photo_loaded('verification'))}"
				) do
					# verification photo
					ImageUpload(
						input_id: "verification-photo",
						fileChanged: proc { |photo_uri| verification_photo_file_changed(photo_uri) },
						can_upload_photo: can_upload_photo,
						showVerificationPhoto: proc { |var| show_verification_photo(var) }) do
						i(class: "fa fa-check f-s-22")

						if params.user.try(:verification_photo_updated_at)
							img(
								class: "",
								onLoad: proc { mutate.photos_loaded['verification'] = true },
								src: params.user.try(:verification_photo_url, 'rect_160')
							)
						end

					end
					# params.user.try(:is_verified) || own
				end
			end

			if can_edit_profile && CurrentUserStore.current_user.present? && !CurrentUserStore.current_user.is_admin? && params.user.try(:rejection_message) && params.user.try(:rejection_message).loaded?
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

	def show_verification_photo var
		mutate.show_verification_photo true
	end

	def can_upload_photo
		!params.user.try(:verification_photo_updated_at) && !params.user.try(:is_verified)
	end

	def should_see_full_verification_photo
		state.show_verification_photo && params.user.try(:verification_photo_updated_at)
	end

	def confirm_deletion index
		mutate.confirm_deletion_index index
		mutate.confirm_on_top_index index

		%x|
			var clickCallback = function(event) {
				if(!event.target.classList.contains('js-propagate')){
					event.stopPropagation()
				}

				event.preventDefault()
				#{confirm_deletion_cancel}
				document.body.removeEventListener('click', clickCallback)
			}

			document.body.addEventListener('click', clickCallback)
		|

		if state.cancel_confirm_timeout
			state.cancel_confirm_timeout.abort
		end
		mutate.cancel_confirm_timeout(after(4) do
			confirm_deletion_cancel
			`document.body.removeEventListener('click', clickCallback)`
		end)
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
		photo.url + '&u=' + (CurrentUserStore.current_user_id.try(:to_s) || '')
		# if photo.is_private
		# 	if can_edit_profile == true || AccessPermission.where_owner(params.user.try(:id)).where_permitted(CurrentUserStore.current_user_id).profile_granted.private_photos_granted.first
		# 		photo["thumbnail_url"]
		# 	else
		# 		photo["blurred_url"]
		# 	end
		# elsif CurrentUserStore.current_user != nil
		# 	photo["thumbnail_url"]
		# else
		# 	photo["blurred_url"]
		# end
	end

	def mocked_image_upload
		span() do
			div(class: "d-flex") do
				label(class: 'mb-0 ea-flex-1') do
					a(class: "add-photo no-underline-i") do
						i(class: "ero-camera f-s-30 text-white")
						span(class: 'first-person mocked-bit-wide-short mt-2')
					end
				end
				label(class: 'mb-0 ea-flex-1') do
					a(id: "js-verification-image", class: "verification no-underline-i") do
						div(class: "verification-text-wrapper") do
							div(class: "verification-text text-center") do
								i(class: "ero-sad-face f-s-30 text-white")
                span(class: 'first-person mocked-bit-wide-short d-block mt-2')
							end
						end
					end
				end
			end
		end
	end

	def can_edit_profile
		CurrentUserStore.current_user.present? && (CurrentUserStore.current_user.is_admin? || CurrentUserStore.current_user_id == params.user.try(:id))
	end

	def open_photo_in_gallery index
		if state.selected_photo_index != index
			# puts "index", index
			mutate.selected_photo_index index
		end
	end

	def update_photo_index index
		if state.selected_photo_index != index
			mutate.selected_photo_index index
		end

		mutate.show_verification_photo false
	end

	def update_photo_mode photo, e = nil
		if e
			e.stop_propagation
		end

		next_mode = (photo.is_private ? "publiczne" : "prywatne")
		UpdatePhotoMode.run({
			photo_id: photo.try(:id)
		})
		.fail do |e|
			handle_errors(e)
		end
	end

	def delete_current_photo index, e = nil
		if e
			e.stop_propagation
		end
		size = state.photos_size
		DeleteUserPhoto.run({
			photo_id: params.user.try(:photos).try(:[], index).try(:id)
		})
		.then do |response|
			size = size - 1
			# mutate.blocking(false)
			mutate.photos_size(size)
			react_to_photo_deletion(index, size)
		end
		.fail do |e|
			# mutate.blocking(false)
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

	def open_gallery_mobile_modal val
		ModalsService.open_modal('ProfileGalleryMobileModal', { size_class: 'modal-lg', user: params.user, photos_size: state.photos_size, selected_photo_index: val, can_edit_profile: can_edit_profile, private_photos_permitted: AccessPermission.where_owner(params.user.try(:id)).where_permitted(CurrentUserStore.current_user_id).profile_granted.private_photos_granted.first, opened: true})
	end

	def react_to_photo_deletion(index, size = state.photos_size)
		# switch to near photo
		last_index = size - 1

		puts "LASTINDEX #{last_index}"
		if index > last_index
			mutate.selected_photo_index(last_index)
			puts "SELETED INDEX #{last_index}"
		else
			mutate.selected_photo_index(index)
		end
	end

	def handle_errors(e)
		`toast.error('Coś poszło nie tak.')`
		puts "#{e}"
		if e.is_a?(ArgumentError)
			mutate.errors e
		elsif e.is_a?(Hyperloop::Operation::ValidationException)
			mutate.errors e.errors.message
		end
	end

	def render_verification_status
		if !params.user.try(:verification_photo_url) && !params.user.try(:is_verified)
			i(class: "ero-sad-face f-s-30 text-white")
			div(class: "f-s-12 text-white mt-1") {'Dodaj zdjęcie weryfikacyjne'}
		elsif params.user.try(:verification_photo_url) && !params.user.try(:is_verified) && !params.user.try(:rejection_message)
			i(class: "ero-sad-face f-s-30 text-white")
			div(class: "f-s-12 text-white mt-1") {'Oczekuje na weryfikacje'}
		elsif params.user.try(:verification_photo_url) && !params.user.try(:is_verified) && params.user.try(:rejection_message)
			i(class: "ero-sad-face f-s-30 text-white")
			div(class: "f-s-12 text-white mt-1") {'Weryfikacja się nie powiodła'}
		elsif params.user.try(:verification_photo_url) && params.user.try(:is_verified) && !params.user.try(:rejection_message)
			i(class: "ero-sad-face f-s-30 text-white")
			div(class: "f-s-12 text-white mt-1") {'Zweryfikowany'}
		end
	end

	def save_gallery_photo
		mutate.normal_photo_loader true
		size = state.photos_size
		SaveUserPhoto.run({
			user_id: params.user.try(:id),
			photo_uri: state.gallery_photo_uri
		})
		.then do |data|
			mutate.normal_photo_loader false
			# LUKAS - Po wgraniu zdjęcia nie animujemy karuzeli
			# mutate.selected_photo_index(size)
		end
		.fail do |e|
			# puts "show_gallery_save_gallery_photo_errors"
			# puts e
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

	def gallery_photo_file_changed data
		mutate.gallery_photo_uri data;
		save_gallery_photo
	end

	def save_verification_photo
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
			# puts "show_gallery_save_verification_photo_errors"
			puts e
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

	def verification_photo_file_changed data
		mutate.verification_photo_uri data;
		save_verification_photo
	end
end