class ProfileDetails < Hyperloop::Router::Component

	SMOKER_OPTIONS = [
		{label: 'Nie palę', value: 'no'},
		{label: 'Czasami', 	value: 'yes'}
	]

	ALCOHOL_OPTIONS = [
		{label: 'Do towarzystwa', value: 'yes'},
		{label: 'Nie przepadam', 	value: 'no'}
	]

	USER_ATTRIBUTES_ARRAY = ["my_expectations", "likes", "dislikes", "ideal_partner", "about_me", "searched_kinds", "weight", "height", "body", "is_smoker", "is_drinker"]

	state :edit do
		{
			likes:    				false,
			dislikes: 				false,
			ideal_partner: 		false,
			my_expectations:	false,
			interest_ids:     false,
			about_me: 				false
		}
	end
	state interests_loaded: false
	state height_loaded: false
	state all_interests: []
	state errors: 	{}
	state blocking: false
	state user: 		{}
	state :user_copy do
		{
			my_expectations: '',
			likes: '',
			dislikes: '',
			ideal_partner: '',

			about_me: '',
			searched_kinds: [],
			weight: 0,
			height: 0,
			body: '',
			is_smoker: false,
			is_drinker: false,
			interest_ids: []
		}
	end

	state interest_options: []
	state selected_height: ''
	state selected_height_copy: ''

	param user: {}
	# param user_id: nil

	before_mount do
		mutate.user params.user
		mutate.all_interests Interest.all
	end

	before_receive_props do |new_params|
		if new_params['user'] != state.user
			mutate.user new_params['user']
		end
	end

	def render

		if state.user.try(:interest_ids).try(:loaded?) && !state.interests_loaded
			mutate.interests_loaded true
			mutate.user_copy['interest_ids'] = state.user.interest_ids.dup
		end

		if state.interest_options.try(:size).try(:to_i) == 0 && state.all_interests.try(:loaded?) && !state.all_interests.map{ |i| i.try(:title).try(:loaded?) }.include?(false)
			mutate.interest_options state.all_interests.select{|i| i.id.to_i > 0}.map { |i| { value: i.id.to_i, label: i.title.to_s } }
		end

		if !state.height_loaded && state.user.try(:height).try(:loaded?)
			mutate.height_loaded true
			choices = Commons::HEIGHT_MAPPING.select { |k, val| val['min'] <= state.user.height && val['max'] >= state.user.height }
			mapped_choices = choices.map { |k, val| { "label": k, "value": val }}
			mutate.selected_height (mapped_choices[0]['label'])
			mutate.selected_height_copy state.selected_height
		end

		div(class: "profile-details-wrapper") do

			div(class: "profile-details will-load #{'not-loaded' if !are_profile_details_loaded?}") do
				PinBlock() if (can_edit_profile && state.user.try(:pin).loaded? && state.user.try(:pin).blank? && CurrentUserStore.current_user && !CurrentUserStore.current_user.is_admin?)

				div(class: "profile-main-section align-items-start align-items-md-center") do

					div(class: "profile-avatar-and-intrests align-items-start #{'make-space-for-report-button' if !can_edit_profile}") do

						# avatar
						div(class: "profile-avatar") do
							div(class: "edit-avatar") do
								i(class: "ero-pencil text-secondary f-s-18")
							end if can_edit_profile
							img(class: "profile-avatar rounded-circle", src: (user_photo))
						end.on :click do |e|
							if !can_edit_profile
								false
							else
								ModalsService.open_modal('ProfileAvatarModal', { user: state.user, photo_id: nil })
							end
						end


						div(class: "profile-intrests") do
							div(class: "hover-div #{'pointer' if can_edit_profile}") do


								# intrests header
								div(class: "profile-intrests-header") do
									h5(class: "mb-0 d-inline-block") {'W celu'}
									i(class: "profile-intrests-edit ero-pencil text-secondary ml-2 mb-1 f-s-18") if can_edit_profile
									# if state.user.try(:interest_ids).try(:loaded?) && state.user.try(:interest_ids) && !state.edit['interest_ids']
									# 	h6(class: "text-book mb-0") { '-' }
									# end
								end

								# intrests badges form params
								# div(class: "profile-intrests-badges-wrapper d-flex flex-wrap align-items-center") do
								# 	if state.user.try(:interests) && !state.user.try(:interests).empty?
								# 		state.user.try(:interests).each do |interest|
								# 			span(class: "badge badge-default") { interest['title'] }
								# 		end
								# 	else
								# 		h6(class: "text-gray-light text-book mr-3 mb-0 d-inline-block") { 'Brak' }
								# 	end
								# end if !state.edit['interest_ids']

								# intrests badges while editing
								selected_interests = state.interest_options.select{ |interest| state.user_copy['interest_ids'] && state.user_copy['interest_ids'].include?(interest['value']) }

								div(class: "profile-intrests-badges-wrapper d-flex flex-wrap align-items-center") do
									if selected_interests && selected_interests.size > 0
										selected_interests.each do |interest|
											span(class: "badge badge-default") { interest["label"] }
										end
									else
										h6(class: "text-gray-light text-book mr-3 mb-0 d-inline-block") { 'Brak' }
									end
								end

							end.on :click do |e|
								edit_generic_section 'interest_ids'
							end


							# multiselect
							div(class: "profile-intrests-multiselect-wrapper") do
								MultiSelectWithCheckboxes(
									placeholder: "W celu",
									selection: state.user_copy['interest_ids'],
									options: state.interest_options,
								).on :change do |e|
									mutate.user_copy['interest_ids'] = e.to_n
									mutate.errors['interest_ids'] = nil
									# puts "state.user.try(:interest_ids) #{state.user.try(:interest_ids)}"
									# puts "state.user_copy['interest_ids'] #{state.user_copy['interest_ids']}"
								end

								render_edit_section_buttons("interest_ids", :save_user_interests)
							end if state.edit['interest_ids']
						end
					end


					# report user
					if CurrentUserStore.current_user_id != state.user.try(:id)
						button(class: "btn btn-outline-primary btn-outline-cancel btn-lg btn-sm-block mb-2 mb-md-0 ml-2 btn-report-user d-none d-md-inline-block", type: "button") do
							span() {'Zgłoś użytkownika'}
						end.on(:click) { report_user state.user }
					end
				end
				div(class: "divider")


				# About me
				div(class: "profile-section") do
					div(class: "profile-section-editable #{'pointer' if can_edit_profile}") do
						# header
						div(class: "profile-section-header pt-3 pb-3") do
							h6(class: "mb-0 d-inline-block") {'O mnie'}
							i(class: "profile-section-edit ero-pencil text-secondary ml-2 mb-1 f-s-18") if can_edit_profile
						end

						# text
						if !state.edit['about_me']
							render_about_me
						end
					end
					.on :click do |e|
						edit_about_me_section
					end

					if state.edit['about_me']
						div(class: "profile-section-edit") do
							render_about_me_edit
						end
					end
				end

				div(class: "divider")

				# section
				div(class: "profile-section") do

					div(class: "profile-section-editable #{'pointer' if can_edit_profile}") do
						# header
						div(class: "profile-section-header pt-3 pb-3") do
							h6(class: "mb-0 d-inline-block") {'Lubię'}
							i(class: "profile-section-edit ero-pencil text-secondary ml-2 mb-1 f-s-18") if can_edit_profile
						end

						# text
						if !state.edit['likes']
							if state.user.try(:likes) && state.user.try(:likes).size != 0
								p(class: "profile-section-text mb-0 pb-3") { state.user.try(:likes) }
							else
								div() do
									h6(class: "profile-section-text-empty text-book text-gray-light d-inline-block mb-0 pb-3") { 'Opis jeszcze nie dodany' }
								end
							end
						end
					end.on :click do |e|
						edit_generic_section 'likes'
					end


					# edit
					if state.edit['likes']
						div(class: "profile-section-edit") do

							FormGroup(label: nil, error: state.errors["likes"], classNames: 'mb-0') do
								textarea(
									defaultValue: state.user_copy["likes"],
									placeholder: "Lubię...",
									name: 'content',
									maxLength: 200,
									class: "form-control resize-none"
								).on :input do |e|
									mutate.errors['likes'] = nil
									mutate.user_copy["likes"] = e.target.value
								end
							end

							div(class: 'textarea-character-left-text') do
								span(class: "text-regular #{'text-danger' if (state.user_copy['likes'] || '').size >= 200}") { "Pozostało #{200 - (state.user_copy['likes'] || '').size} znaków" }
							end
							render_edit_section_buttons("likes", :save_user_likes)
						end
					end
				end

				div(class: "divider")

				# section
				div(class: "profile-section") do

					div(class: "profile-section-editable #{'pointer' if can_edit_profile}") do
						# header
						div(class: "profile-section-header pt-3 pb-3") do
							h6(class: "mb-0 d-inline-block") {'Nie lubię'}
							i(class: "profile-section-edit ero-pencil text-secondary ml-2 mb-1 f-s-18") if can_edit_profile
						end

						# text
						if !state.edit['dislikes']
							if state.user.try(:dislikes) && state.user.try(:dislikes).size != 0
								p(class: "profile-section-text mb-0 pb-3") { state.user.try(:dislikes) }
							else
								div() do
									h6(class: "profile-section-text-empty text-book text-gray-light d-inline-block mb-0 pb-3") { 'Opis jeszcze nie dodany' }
								end
							end
						end
					end.on :click do |e|
						edit_generic_section 'dislikes'
					end


					# edit
					if state.edit['dislikes']
						div(class: "profile-section-edit") do

							FormGroup(label: nil, error: state.errors["dislikes"], classNames: 'mb-0') do
								textarea(
									defaultValue: state.user_copy["dislikes"],
									placeholder: "Nie lubię...",
									name: 'content',
									maxLength: 200,
									class: "form-control resize-none"
								).on :input do |e|
									mutate.errors['dislikes'] = nil
									mutate.user_copy["dislikes"] = e.target.value
								end
							end

							div(class: 'textarea-character-left-text') do
								span(class: "text-regular #{'text-danger' if (state.user_copy['dislikes'] || '').size >= 200}") { "Pozostało #{200 - (state.user_copy['dislikes'] || '').size} znaków" }
							end
							render_edit_section_buttons("dislikes", :save_user_dislikes)
						end
					end
				end

				div(class: "divider")

				# section
				div(class: "profile-section") do

					div(class: "profile-section-editable #{'pointer' if can_edit_profile}") do
						# header
						div(class: "profile-section-header pt-3 pb-3") do
							h6(class: "mb-0 d-inline-block") {'Wymarzony partner'}
							i(class: "profile-section-edit ero-pencil text-secondary ml-2 mb-1 f-s-18") if can_edit_profile
						end

						# text
						if !state.edit['ideal_partner']
							if state.user.try(:ideal_partner) && state.user.try(:ideal_partner).size != 0
								p(class: "profile-section-text mb-0 pb-3") { state.user.try(:ideal_partner) }
							else
								div() do
									h6(class: "profile-section-text-empty text-book text-gray-light d-inline-block mb-0 pb-3") { 'Opis jeszcze nie dodany' }
								end
							end
						end
					end.on :click do |e|
						edit_generic_section 'ideal_partner'
					end


					# edit
					if state.edit['ideal_partner']
						div(class: "profile-section-edit") do

							FormGroup(label: nil, error: state.errors["ideal_partner"], classNames: 'mb-0') do
								textarea(
									defaultValue: state.user_copy["ideal_partner"],
									placeholder: "Wymarzony partner...",
									name: 'content',
									maxLength: 200,
									class: "form-control resize-none"
								).on :input do |e|
									mutate.errors['ideal_partner'] = nil
									mutate.user_copy["ideal_partner"] = e.target.value
								end
							end

							div(class: 'textarea-character-left-text') do
								span(class: "text-regular #{'text-danger' if (state.user_copy['ideal_partner'] || '').size >= 200}") { "Pozostało #{200 - (state.user_copy['ideal_partner'] || '').size} znaków" }
							end
							render_edit_section_buttons("ideal_partner", :save_user_ideal_partner)
						end
					end
				end

				div(class: "divider")
			end

			div(class: "profile-details-loading #{'d-none' if are_profile_details_loaded?}") do
				div(class: 'dots-container') do
				  div(class: 'animated-dots') do
				    span {'.'}
				    span {'.'}
				    span {'.'}
				  end
				end
			end

			groups = state.user.try(:id).present? ? UserGroup.unscoped.where_user(state.user.try(:id)) : []

			if ((state.user.try(:privacy_settings).present? && state.user.privacy_settings["show_groups"]) || can_edit_profile) && groups.try(:loaded?) && (groups.try(:count) || 0) > 0
				ProfileGroups(user: state.user)
			end
		end

	end

	def render_about_me
		if !!state.user.try(:about_me) && state.user.try(:about_me).size != 0
			p(class: "profile-section-text text-gray text-book mb-0 pb-3") { state.user.try(:about_me) }
		else
			h6(class: "text-book text-gray-light d-inline-block mb-0") { 'Opis jeszcze nie dodany' }
		end

		div(class: "profile-preferences") do
			div(class: "row") do
				div(class: "col-12 col-md-6 pt-3 pb-3 border-right") do
					div(class: "row mb-3") do
						div(class: "col-6") do
							h6 {'Szukam'}
						end
						div(class: "col-6") do
							span(class: 'profile-preferences-text') do
								if state.user.try(:searched_kinds) && !state.user.try(:searched_kinds).empty?
									Commons.account_kinds_declined.select{ |kind| (state.user.try(:searched_kinds) || []).include?(kind['value']) }.map{ |v| v['label'] }.join(', ')
								else
									span { '-' }
								end
							end
						end
					end
					div(class: "row mb-3") do
						div(class: "col-6") do
							h6 {'Waga'}
						end
						if state.user.try(:weight)
							div(class: "col-6 profile-preferences-text") { state.user.try(:weight).to_s }
						else
							div(class: "col-6 profile-preferences-text") { '-' }
						end
					end
					div(class: "row") do
						div(class: "col-6") do
							h6 {'Wzrost'}
						end
						if state.user.try(:height)
							div(class: "col-6 profile-preferences-text") { state.selected_height }
						else
							div(class: "col-6 profile-preferences-text") { '-' }
						end
					end
				end
				div(class: "col-12 col-md-6 pt-3 pb-3") do
					div(class: "row mb-3") do
						div(class: "col-6") do
							h6 {'Sylwetka'}
						end
						if state.user.try(:body)
							div(class: "col-6 profile-preferences-text") { state.user.try(:body) }
						else
							div(class: "col-6 profile-preferences-text") { '-' }
						end
					end
					div(class: "row mb-3") do
						div(class: "col-6") do
							h6 {'Papierosy'}
						end
						div(class: "col-6 profile-preferences-text") do
							selected_option = SMOKER_OPTIONS.select{ |option| option["value"] === (state.user.try(:is_smoker) ? 'yes' : 'no') }
							if selected_option && selected_option.first
								selected_option.first["label"]
							else
								"Brak wyboru"
							end
						end
					end
					div(class: "row") do
						div(class: "col-6") do
							h6 {'Alkohol'}
						end
						div(class: "col-6 profile-preferences-text") do
							selected_option = ALCOHOL_OPTIONS.select{ |option| option["value"] === (state.user.try(:is_drinker) ? 'yes' : 'no') }
							if selected_option && selected_option.first
								selected_option.first["label"]
							else
								"Brak wyboru"
							end
						end
					end
				end
			end
		end
	end

	def has_errors(field)
		state.errors && state.errors[field] && !state.errors[field].empty?
	end

	def render_about_me_edit
		FormGroup(label: nil, error: state.errors["about_me"], classNames: 'mb-0') do
			textarea(
				defaultValue: state.user.try(:about_me),
				placeholder: "Tekst...",
				name: 'content',
				maxLength: 200,
				class: "form-control resize-none"
			).on :input do |e|
				mutate.errors['about_me'] = nil
				mutate.user["about_me"] = e.target.value
			end
		end

		div(class: 'textarea-character-left-text') do
			span(class: "text-regular #{'text-danger' if (state.user.try(:about_me) || '').try(:size).try(:>=, 200)}") { "Pozostało #{200 - (state.user.try(:about_me) || '').try(:size) || 0} znaków" }
		end

		div(class: "profile-preferences") do
			div(class: "row") do
				div(class: "col-12 col-md-6 pt-3 border-right") do
					div(class: "row mb-3") do
						div(class: "col-4") do
							h6 {'Szukam'}
						end
						div(class: 'col-8 text-gray') do

							FormGroup(label: nil, error: state.errors['searched_kinds']) do
								MultiSelectWithCheckboxes(
									placeholder: "Szukam",
									options: Commons.account_kinds_declined,
									selection: state.user.try(:searched_kinds),
									className: "form-control #{'is-invalid' if has_errors('searched_kinds')}"
								).on :change do |e|
									mutate.user["searched_kinds"] = e.to_n
									mutate.errors['searched_kinds'] = nil
								end
							end

						end
					end
					div(class: "row mb-3") do
						div(class: "col-4") do
							h6 {'Waga'}
						end
						div(class: 'col-8 text-gray') do
							FormGroup(error: state.errors['weight']) do
								input(
									defaultValue: state.user.try(:weight),
									type: "number",
									class: "form-control #{'is-invalid' if has_errors('weight')}",
									placeholder: "Waga"
								).on :key_up do |e|
									mutate.user["weight"] = e.target.value
									mutate.errors['weight'] = nil
								end
							end
						end
					end
					div(class: "row") do
						div(class: "col-4") do
							h6 {'Wzrost'}
						end
						div(class: 'col-8 text-gray') do
							FormGroup(error: state.errors['height']) do

								SelectWithCheckboxes(
									class: "form-control #{'is-invalid' if has_errors('body')}",
									placeholder: "Wzrost",
									name: 'height_in[]',
									selection: state.selected_height,
									clearable: false,
									options: Commons::HEIGHT_MAPPING.keys.map { |k| { "label": k, "value": k }}
								).on :change do |e|
									if e.to_n

										median = (Commons::HEIGHT_MAPPING[e.to_n]['min'] + Commons::HEIGHT_MAPPING[e.to_n]['max']) / 2

										choices = Commons::HEIGHT_MAPPING.select { |k, val| val['min'] <= median && val['max'] >= median }

										mapped_choices = choices.map { |k, val| { "label": k, "value": val }}
										# puts "mapped_choices #{mapped_choices[0]['label']}"

										mutate.selected_height mapped_choices[0]['label']
										mutate.user['height'] = median
									end
								end
							end

						end
					end
				end
				div(class: "col-12 col-md-6 pt-3") do
					div(class: "row mb-3") do
						div(class: "col-4") do
							h6 {'Sylwetka'}
						end
						div(class: "col-8 text-gray") do
							FormGroup(error: state.errors['body']) do
								SelectWithCheckboxes(
									class: "form-control #{'is-invalid' if has_errors('body')}",
									placeholder: "Sylwetka",
									name: 'body_in[]',
									selection: state.user.try(:body),
									clearable: false,
									options: Commons::BODY_TYPES.map {|e| { value: e, label: e} }
								).on :change do |e|
									mutate.user['body'] = e.to_n
									mutate.errors['body'] = nil
								end
							end
						end
					end
					div(class: "row mb-3") do
						div(class: "col-4") do
							h6 {'Papierosy'}
						end
						div(class: "col-8 text-gray") do
							FormGroup(error: state.errors['is_smoker']) do
								SelectWithCheckboxes(
									placeholder: "Papierosy",
									options: SMOKER_OPTIONS,
									clearable: false,
									selection: (state.user.try(:is_smoker) ? 'yes' : 'no'),
									className: "form-control #{'is-invalid' if has_errors('is_smoker')}",
									onChange: proc { |e| smoker_changed(e) }
								)
							end
						end
					end
					div(class: "row") do
						div(class: "col-4") do
							h6 {'Alkohol'}
						end
						div(class: "col-8 text-gray") do
							FormGroup(error: state.errors['is_drinker']) do
								SelectWithCheckboxes(
									placeholder: "Alkohol",
									options: ALCOHOL_OPTIONS,
									clearable: false,
									selection: (state.user.try(:is_drinker) ? 'yes' : 'no'),
									className: "form-control #{'is-invalid' if has_errors('is_drinker')}",
									onChange: proc { |e| alcohol_changed(e) }
								)
							end
						end
					end
				end
			end
		end

		render_edit_section_buttons("about_me", :save_user_about_me)
	end

	def are_profile_details_loaded?
		state.user.present? && state.user.try(:searched_kinds).loaded? && state.user.try(:about_me).loaded? && state.user.try(:body).loaded? && state.user.try(:is_smoker).loaded? && state.user.try(:is_drinker).loaded? && state.user.try(:weight).loaded? && state.user.try(:height).loaded? && state.user.try(:interest_ids).loaded? && state.user.try(:likes).loaded? && state.user.try(:dislikes).loaded? && state.user.try(:ideal_partner).loaded?
	end

	def edit_about_me_section
		if !can_edit_profile
			false
		else
			mutate.edit["about_me"] = !state.edit["about_me"]

			USER_ATTRIBUTES_ARRAY.each do |attr|
				mutate.user_copy[attr] = state.user[attr]
				mutate.selected_height_copy state.selected_height
			end
		end
	end

	def edit_generic_section section_name
		if !can_edit_profile
			false
		else
			mutate.edit["#{section_name}"] = !state.edit["#{section_name}"]
			mutate.user_copy["#{section_name}"] = state.user["#{section_name}"]
		end
	end

	def can_edit_profile
		CurrentUserStore.current_user && (CurrentUserStore.current_user.is_admin == true || params.user.try(:id) == CurrentUserStore.current_user_id)
	end

	def render_edit_section_buttons editable_section, save_action

		div(class: "profile-section-buttons d-flex justify-content-center") do
			button(class: "btn btn-secondary ml-0 ml-md-2 btn-sm", type:"submit") do
				"Zapisz"
			end.on(:click) do
				try(save_action)
			end

			button(class: "btn btn-outline-primary btn-outline-cancel text-gray ml-2 btn-sm") do
				"Anuluj"
			end.on(:click) do |e|

				e.stop_propagation

				# Restore user's data after cancel
				if editable_section == 'about_me'
					USER_ATTRIBUTES_ARRAY.each do |attr|
						mutate.user[attr] = state.user_copy[attr]
						mutate.selected_height state.selected_height_copy
					end
				else
					mutate.user_copy["#{editable_section}"] = state.user["#{editable_section}"]
				end
				mutate.edit[editable_section] = false
			end
		end
	end

	def smoker_changed e
		mutate.user["is_smoker"] = (e == 'yes' ? true : false)
	end

	def alcohol_changed e
		mutate.user["is_drinker"] = (e == 'yes' ? true : false)
	end

	def save_user_about_me
		mutate.blocking(true)
		SaveUserAboutMe.run({
			user_id: 				state.user.try(:id),
			about_me: 			state.user.try(:about_me),
			searched_kinds: state.user.try(:searched_kinds),
			body: 					state.user.try(:body),
			is_smoker: 			state.user.try(:is_smoker),
			is_drinker: 		state.user.try(:is_drinker),
			weight: 				state.user.try(:weight),
			height: 				state.user.try(:height)
			# ,
			# interest_ids: 	state.user.try(:interest_ids)
		})
		.then do |response|
			mutate.edit["about_me"] = false;
			mutate.blocking(false)
		end
		.fail do |e|
			# puts "ERRORS: #{e.inspect}"
			mutate.blocking(false)
			handle_errors(e)
		end
	end

	def save_user_interests
		mutate.blocking(true)
		# mutate.errors["my_expectations"] = {}
		SaveUserInterests.run({
			user_id: state.user.try(:id),
			interest_ids: state.user_copy["interest_ids"]
		})
		.then do |response|
			# puts 'saved!'
			mutate.edit["interest_ids"] = false;
			mutate.blocking(false)
		end
		.fail do |e|
			mutate.blocking(false)
			handle_errors(e)
		end
	end

	def save_user_likes
		mutate.blocking(true)
		# mutate.errors["likes"] = {}
		SaveUserLikes.run({
			user_id: state.user.try(:id),
			likes: state.user_copy["likes"]
		})
		.then do |response|
			mutate.edit["likes"] = false;
			mutate.blocking(false)
		end
		.fail do |e|
			mutate.blocking(false)
			handle_errors(e)
		end
	end

	def save_user_dislikes
		mutate.blocking(true)
		# mutate.errors["dislikes"] = {}
		SaveUserDislikes.run({
			user_id: state.user.try(:id),
			dislikes: state.user_copy["dislikes"]
		})
		.then do |response|
			mutate.edit["dislikes"] = false;
			mutate.blocking(false)
		end
		.fail do |e|
			mutate.blocking(false)
			handle_errors(e)
		end
	end

	def save_user_ideal_partner
		mutate.blocking(true)
		# mutate.errors["ideal_partner"] = {}
		SaveUserIdealPartner.run({
			user_id: state.user.try(:id),
			ideal_partner: state.user_copy["ideal_partner"]
		})
		.then do |response|
			mutate.edit["ideal_partner"] = false;
			mutate.blocking(false)
		end
		.fail do |e|
			mutate.blocking(false)
			handle_errors(e)
		end
	end

	def handle_errors(e)
		`toast.error('Coś poszło nie tak.')`
		if e.is_a?(ArgumentError)
			mutate.errors e
		elsif e.is_a?(Hyperloop::Operation::ValidationException)
			# puts "VALIDATION EXCEPTION"
			# puts e.errors.message
			mutate.errors e.errors.message
		end
	end

	def report_user user
		if CurrentUserStore.current_user.blank?
			ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('UserAlert', { size_class: 'modal-md', resource_id: user.id, resource_type: 'User' } ) } })
			close
		else
			ModalsService.open_modal('UserAlert', { size_class: 'modal-md', resource_id: user.id, resource_type: 'User' })
		end
	end

	def user_photo
		if state.user.try(:id) == CurrentUserStore.current_user_id && state.user.try(:my_avatar_url)
			state.user.my_avatar_url
		elsif state.user.try(:avatar_url)
			state.user.avatar_url
		else
			return '/assets/user-blank.png'
		end
	end
end