class GallerySlider < Hyperloop::Component
	param user: nil, nils: true
	# param photos: []
	param photos_size: nil
	param selected_photo_index: nil
	param onDelete: nil
	param onModeChange: nil
	param onClick: nil
	param onPhotoChange: nil, nils: true
	param can_edit_profile: false       # is admin or owner
	param private_photos_permitted: nil # is permitted by profile owner to view private photos
	param show_no_photos: false

	state index: 0
	state errors: {}
	state confirm_deletion_visble: false
	state confirm_deletion_on_top: false
	state cancel_confirm_timeout: nil
	state action_buttons_opened: false

	state gallery_step: 0

	state photos_loaded: {}

	state skip_next_photo_change: false

	before_mount do
		mutate.photos_loaded {}
	end

	before_receive_props do |next_props|
		# puts next_props
		mutate.gallery_step next_props[:selected_photo_index]

		if React::IsomorphicHelpers.on_opal_client?

			# photos_container_width = !refs['photoWrapperRef'].nil? ? refs['photoWrapperRef'].clientWidth : 0
			# puts "NEXT PROPS, WIDTH: #{photos_container_width}"

			if state.skip_next_photo_change
				mutate.skip_next_photo_change false
			else
				if next_props[:selected_photo_index] == 0
					show_photo_in_slider 0
				elsif (next_props[:selected_photo_index] || 0) > 0
					show_photo_in_slider -100 * next_props[:selected_photo_index]
				end
			end

			if next_props[:photos_size].present? && next_props[:photos_size].try(:loaded?) && state.gallery_step > next_props[:photos_size].to_i - 1
				mutate.gallery_step next_props[:photos_size].to_i - 1
				updade_selected_photo_in_parent(state.gallery_step)
				show_photo_in_slider(-100 * state.gallery_step)
			end
		end
	end

	after_mount do
		mutate.action_buttons_opened false
	end

	after_mount do
		`
			document.addEventListener('touchstart', handleTouchStart, false);
			document.addEventListener('touchmove', handleTouchMove, false);

			var xDown = null;
			var yDown = null;

			function handleTouchStart(evt) {
			  xDown = evt.touches[0].clientX;
			  yDown = evt.touches[0].clientY;
			}

			function handleTouchMove(evt) {
		    if ( !xDown || !yDown ) {
		      return
		    }

		    var xUp = evt.touches[0].clientX;
		    var yUp = evt.touches[0].clientY;

		    var xDiff = xDown - xUp;
		    var yDiff = yDown - yUp;

		    if ( Math.abs( xDiff ) > Math.abs( yDiff ) ) {
	        if ( xDiff > 0 ) {
	            #{show_next}
	        } else {
	            #{show_previous}
	        }
		    }
		    xDown = null;
		    yDown = null;
			};
		`
	end

	def set_as_avatar
    ModalsService.open_modal('ProfileAvatarModal', {user: CurrentUserStore.current_user, photo_id: photos_scope[state.gallery_step].id} )
	end

	def render
		div(class: "profile-gallery streach-me #{'open' if GalleryStore.is_open} #{'gallery-no-photos' if params.photos_size == 0}") do
			photos_scope = Photo.where_user(params.user.try(:id)).order_by_privacy

			# no photos
			div(class: "profile-gallery-no-photos") do
				div(class: "d-flex flex-column align-items-center") do
					i(class: "fa fa-picture-o")
					span(class: "text-white mt-1 text-regular") {'Brak zdjęć'}
				end
			end if params.photos_size == 0 && params.show_no_photos == true

			div(class: "profile-gallery-inner-static") do

				div(class: "profile-gallery-inner-dynamic", ref: "galleryInnerDynamic") do

					photos_scope.group_by{ |p| !!p.is_private }.each do |is_private, photos|

						if is_private == false || params.user.try(:privacy_settings).try(:[], 'show_blurred') == true || params.can_edit_profile || params.private_photos_permitted

							photos.each_with_index do |photo, index|

								div(class: "gallery-slider-photo-wrapper", ref: "photoWrapperRef") do

									div(class: "gallery-slider-img will-load #{'not-loaded' if !is_photo_loaded(photo.try(:id).to_s)}") do
										img(
											class: "gallery-slider-photo img-fit",
											onLoad: proc { mutate.photos_loaded[photo.id.to_s] = true },
											src: photo_url(photo)
										).on :click do
											photo_clicked_mobile photo.id, photos_scope
										end
									end

									div(class: "gallery-slider-img-loading #{'d-none' if is_photo_loaded(photo.try(:id).to_s)}") do
										div(class: 'dots-container') do
										  div(class: 'animated-dots') do
										    span {'.'}
										    span {'.'}
										    span {'.'}
										  end
										end
									end

									div(class: "gallery-locked will-load #{'not-loaded' if !is_photo_loaded(photo.try(:id).to_s)}") do
										div(class: "d-flex flex-column align-items-center justify-content-center") do
											i(class: "ero-locker")

											button(class: "request-access-button btn btn-secondary btn-lg text-white #{'disabled' if private_photos_request_sent}", type: "button") do
												if !private_photos_request_sent
													span() {'Poproś o dostęp'}
												else
													span() {'Prośba została wysłana'}
												end
											end.on :click do
												RequestAccess.run(owner_id: params.user.id, type: "private_photos")
												.fail do |error|
													`toast.error("Przepraszamy, wystąpił błąd.")`
												end
											end
										end
									end if photo_is_private_for_visitor(photo.id, photos_scope)

									# private photo overlay
									div(class: "photo-private will-load #{'not-loaded' if !is_photo_loaded(photo.try(:id).to_s)}") do
										div(class: "d-flex flex-column align-items-center justify-content-center") do
											i(class: "ero-locker")

											button(class: "request-access-button btn btn-secondary btn-lg text-white", type: "button") do
												span() {'Ustaw jako publiczne'}
											end.on :click do
												toggle_photo_mode_privacy(photos_scope)
											end
										end
									end if photo_is_private_for_gallery_owner(photo.id, photos_scope)

								end
							end

						else
							div(class: "gallery-slider-photo-wrapper") do
								div(class: "gallery-locked") do
									div(class: "d-flex flex-column align-items-center justify-content-center") do
										i(class: "ero-locker")
										# span(class: "text-white text-regular mt-4 mb-4") {'To zdjęcie jest w galerii prywatnej'}

										button(class: "request-access-button btn btn-secondary btn-lg text-white #{'disabled' if private_photos_request_sent}", type: "button") do
											if !private_photos_request_sent
												span() {'Poproś o dostęp'}
											else
												span() {'Prośba została wysłana'}
											end
										end.on :click do
											if CurrentUserStore.current_user.blank?
												ModalsService.open_modal('RegistrationModal', { callback: proc { request_access_to_photos } })
											end
										end
									end
								end
							end
						end

					end
				end


				div(class: "gallery-count") do
					span do
						if (params.photos_size || 0) > 0
							"#{state.gallery_step + 1}/#{params.photos_size}"
						else
							"0/0"
						end
					end
				end

				# action buttons
				div(class: "action-buttons") do
					button(class: "btn btn photo-action-button icon-only btn-small-dark mr-1") do
						if !state.action_buttons_opened
							span() { "..." }
						elsif state.action_buttons_opened
							i(class:"ero-cross rotated-45deg f-s-12")
						end
					end.on :click do
						mutate.action_buttons_opened !state.action_buttons_opened
					end

					div(class: "action-buttons-inner #{'active' if state.action_buttons_opened}") do
						button("data-tip": "", "data-for": "gallery-slider-avatar", class: "btn btn photo-action-button icon-only btn-small-dark mr-1") do
							i(class: "ero-user f-s-18")
						end.on :click do |e|
							set_as_avatar
						end
						ReactTooltip("id": "gallery-slider-avatar", class: 'customeTheme', "place": "bottom", "effect": "solid") do
							div { "Ustaw jako" }
							div { "avatar" }
						end
						button("data-tip": "", "data-for": "gallery-slider-lock", class: "btn btn photo-action-button gallery-lock #{'active' if (photo_present(photos_scope) && photos_scope[state.gallery_step].try(:is_private))} icon-only btn-small-dark mr-1") do
							i(class: "ero-locker f-s-20")
						end.on :click do |e|
							toggle_photo_mode_privacy(photos_scope)
						end
						ReactTooltip("id": "gallery-slider-lock", class: 'customeTheme', "place": "bottom", "effect": "solid") do
							div { "Ustaw jako" }
							div { (photo_present(photos_scope) && photos_scope[state.gallery_step].try(:is_private)) ? "Publiczne" : "Prywatne" }
						end
						button("data-tip": "", "data-for": "gallery-slider-delete", class: "btn btn photo-action-button icon-only btn-small-dark mr-1") do
							i(class: "ero-trash f-s-18")
						end.on :click do |e|
							confirm_deletion
						end
						ReactTooltip("id": "gallery-slider-delete", class: 'customeTheme', "place": "bottom", "effect": "solid") do
							span { "Usuń" }
						end
					end
				end if params.can_edit_profile == true


				div(class: "gallery-close") do
					button(class: "btn icon-only btn-big-dark", type:"button") do
						i(class: "ero-cross rotated-45deg")
					end
				end.on :click do |e|
					GalleryStore.toggle_open false
				end

				div(class: "navigate-left-area") do
					""
				end.on :click do |e|
					e.prevent_default
					show_previous(e)
				end
				div(class: "navigate-right-area") do
					""
				end.on :click do |e|
					e.prevent_default
					show_next(e)
				end

				a(class: "chevron-left-big #{'d-none' if params.photos_size == 0}") do
					i(class: "ero-chevron-left-big")
				end.on :click do |e|
					show_previous(e)
				end

				a(class: "chevron-right-big #{'d-none' if params.photos_size == 0}") do
					i(class: "ero-chevron-right-big")
				end.on :click do |e|
					show_next(e)
				end

				div(class: "confirm-deletion #{'on-top' if state.confirm_deletion_on_top} #{'active' if state.confirm_deletion_visible}") do
					button(class: "btn icon-only btn-container text-secondary white-border white-bg js-propagate") do
						i(class: "ero-trash f-s-24 text-secondary text-center js-propagate")
					end.on :click do |e|
						e.stop_propagation
						e.prevent_default
						delete_current
					end
					span(class: "text-white f-s-18 mt-2") {'Usuń zdjęcie'}
				end
			end if (params.photos_size || 0) > 0
		end
	end

	def is_photo_loaded attr
		state.photos_loaded[attr]
	end

	def private_photos_request_sent
		if CurrentUserStore.current_user && CurrentUserStore.current_user_id && params.user.try(:id)
		  if photo_request = AccessPermission.where_owner(params.user.try(:id)).where_permitted(CurrentUserStore.current_user_id).first
		    if photo_request.present? && photo_request.id.present? && photo_request.id.loaded?
		      true
		    else
		      false
		    end
		  else
		    false
		  end
		else
		  false
		end
	end

	def request_access_to_photos
		RequestAccess.run(owner_id: params.user.id, type: "private_photos")
		.fail do |error|
			`toast.error("Przepraszamy, wystąpił błąd.")`
		end
	end

	def photo_url photo
		photo.full_url + '&u=' + (CurrentUserStore.current_user_id.try(:to_s) || '') + "#{params.private_photos_permitted ? '1' : '0'}"
		# if photo.is_private
		# 	if (CurrentUserStore.current_user != nil && (params.can_edit_profile == true || params.private_photos_permitted))
		# 		photo.url
		# 	else
		# 		photo.blurred_full_url
		# 	end
		# elsif CurrentUserStore.current_user != nil
		# 	photo.url
		# else
		# 	photo.blurred_full_url
		# end
	end

	def photo_is_private_for_visitor id, photos_scope
		if photos_scope.present? && photos_scope.try(:loaded?)
			index = photos_scope.index{ |p| p.id == id }
			result = photos_scope[index].is_private && (CurrentUserStore.current_user_id.blank? || (!params.can_edit_profile && !params.private_photos_permitted))
		else
			result = false
		end
		# puts "IS PRIVATE #{result} #{index}, #{photos_scope[index].is_private}"
		result
	end

	def photo_is_private_for_gallery_owner id, photos_scope
		if photos_scope.present?
			index = photos_scope.index{ |p| p.id == id }
			if photos_scope[index].is_private
				photos_scope[index].is_private && (CurrentUserStore.current_user_id && CurrentUserStore.current_user_id == params.user.try(:id))
			else
				false
			end
		end
	end

	def confirm_deletion id
		mutate.confirm_deletion_visible true
		mutate.confirm_deletion_on_top true

		%x|
			clickCallback = function(event) {
				if(!event.target.classList.contains('js-propagate')){
					event.stopPropagation()
				}

				event.preventDefault()
				#{confirm_deletion_cancel}
				document.body.removeEventListener('click', clickCallback)
			}

			document.body.addEventListener('click', clickCallback)
		|

		# if state.cancel_confirm_timeout
		# 	state.cancel_confirm_timeout.abort
		# end
		# mutate.cancel_confirm_timeout(after(4) do
		# 	confirm_deletion_cancel
		# 	`document.body.removeEventListener('click', clickCallback)`
		# end)
	end

	def confirm_deletion_cancel
		mutate.confirm_deletion_visible false
		after(0.41) do
			mutate.confirm_deletion_on_top false
		end
	end

	def slide_photos amount
		# Element['.profile-gallery-inner-dynamic'].css(transform: "translateX( #{ amount }px )", transition: "all 0.3s ease")
		# puts "HALO SLIDE: #{refs['galleryInnerDynamic'].try(:className)}, #{`document.getElementsByClassName('profile-gallery-inner-dynamic')`}"
		# `
		# 	items = document.getElementsByClassName('profile-gallery-inner-dynamic');
		# 	for (i=0;i<items.length;i++) {
		# 		items[i].style['transition'] = "all 0.3s ease";
		# 		items[i].style['transform'] = "translateX( #{ amount }px )";
		# 		console.log('HALOO', #{amount})
		# 	}
		# `
		# .each(function(el) {el.style['transition'] = "all 0.3s ease"; el.style['transform'] = "translateX( #{ amount }px )"})
		if !refs['galleryInnerDynamic'].nil?
			refs['galleryInnerDynamic'].style['transition'] = "all 0.3s ease"
			after 0 do
				refs['galleryInnerDynamic'].style['transform'] = "translateX( #{ amount }% )"
			end
		end
	end

	def show_photo_in_slider amount
		# puts "AMOUNT: #{amount}"
		# Element['.profile-gallery-inner-dynamic'].css(transform: "translateX( #{ amount }px )", transition: "")
		# puts "HALO SHOW: #{refs['galleryInnerDynamic'].try(:className)}, #{`document.getElementsByClassName('profile-gallery-inner-dynamic')`}"
		# `document.getElementsByClassName('profile-gallery-inner-dynamic').each(function(el) {el.style['transition'] = ""; el.style['transform'] = "translateX( #{ amount }px )"})`
		# `
		# 	items = document.getElementsByClassName('profile-gallery-inner-dynamic');
		# 	for (i=0;i<items.length;i++) {
		# 		items[i].style['transition'] = "";
		# 		items[i].style['transform'] = "translateX( #{ amount }px )";
		# 	}
		# `
		# `document.getElementsByClassName('profile-gallery-inner-dynamic').each(function(el) {el.style['transition'] = ""})`
		if !refs['galleryInnerDynamic'].nil?
			refs['galleryInnerDynamic'].style['transition'] = ""
			after 0 do
				refs['galleryInnerDynamic'].style['transform'] = "translateX( #{ amount }% )"
			end
		end
	end

	def photo_present photos_scope
		photos_scope[state.index].present?
	end

	def show_next e
		if e
			e.stop_propagation
		end

		if React::IsomorphicHelpers.on_opal_client?
			# photos_container_width = !refs['photoWrapperRef'].nil? ? refs['photoWrapperRef'].clientWidth : 0
			# puts "WIDTH: #{refs['photoWrapperRef'].try(:clientWidth)}"

			# puts "params.photos_size: #{params.photos_size}"
			if params.photos_size > 1
				if state.gallery_step == 0
					mutate.gallery_step (state.gallery_step + 1)
					updade_selected_photo_in_parent(state.gallery_step)
					slide_photos(-100)

				elsif (state.gallery_step || 0) > 0 && state.gallery_step != params.photos_size - 1
					mutate.gallery_step (state.gallery_step + 1)
					updade_selected_photo_in_parent(state.gallery_step)
					slide_photos(-100 * state.gallery_step)

				elsif (state.gallery_step || 0) > 0 && state.gallery_step == params.photos_size - 1
					mutate.gallery_step 0
					updade_selected_photo_in_parent(state.gallery_step)
					slide_photos 0
				end
			end
		end

		# puts "state.gallery_step #{state.gallery_step}"
	end

	def show_previous e
		if e
			e.stop_propagation
		end

		if React::IsomorphicHelpers.on_opal_client?
			photos_container_width = !refs['photoWrapperRef'].nil? ? refs['photoWrapperRef'].clientWidth : 0

			if params.photos_size > 1

				if state.gallery_step == 0
					mutate.gallery_step (params.photos_size - 1)
					updade_selected_photo_in_parent(state.gallery_step)
					slide_photos -100 * (params.photos_size - 1)

				elsif (state.gallery_step || 0) > 0
					mutate.gallery_step (state.gallery_step - 1)
					updade_selected_photo_in_parent(state.gallery_step)
					slide_photos -100 * state.gallery_step
				end

			end
		end
		# puts "state.gallery_step #{state.gallery_step}"
	end

	def delete_current
		if params.onDelete
			params.onDelete.call(state.gallery_step)
		end
	end

	def toggle_photo_mode_privacy photos_scope
		if params.onModeChange
			params.onModeChange.call(photos_scope[state.gallery_step])
		end
	end

	def photo_clicked_mobile id, photos_scope
		if params.onClick && (photos_scope.try(:count) || 0) > 0
			index = photos_scope.index{ |p| p.id == id }
			params.onClick.call(index)
		end
	end

	def updade_selected_photo_in_parent step
		if params.onPhotoChange
			mutate.skip_next_photo_change true
			params.onPhotoChange.call(step)
		end
	end

	def handle_errors(e)
		# puts "handle_errors"
		# puts e
		# puts "#{e}"
		`toast.error('Coś poszło nie tak.')`
		if e.is_a?(ArgumentError)
			mutate.errors e
		elsif e.is_a?(Hyperloop::Operation::ValidationException)
			# puts "ValidationException@gallery_slider"
			# puts e.errors.message
			mutate.errors e.errors.message
		end
	end
end