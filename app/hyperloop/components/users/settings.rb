class ProfileSettings < Hyperloop::Router::Component

	state blocking: false
	state errors: {}
	state user: {}
	state user_copy: {}

	state password: ''
	state new_email: ''
	state new_email_confirmation: ''

	state old_password: ''
	state new_password: ''
	state new_password_confirmation: ''

	state :old_pin
	state :new_pin
	state :new_pin_confirmation

	state :edit do
		{
			name:    				false
		}
	end

	MAP_OPTIONS = {
		types: ['(cities)'],
		componentRestrictions: {country: 'pl'}
	}

	CSS_CLASSES = {
		root: 'google-places',
		input: 'form-control',
		autocompleteContainer: 'autocomplete-container'
	}

	INVALID_CSS_CLASSES = {
		root: 'google-places',
		input: 'form-control is-invalid',
		autocompleteContainer: 'autocomplete-container'
	}

	before_mount do
		mutate.blocking false
		mutate.user CurrentUserStore.current_user
		if state.user.blank?
			CurrentUserStore.on_current_user_load proc { not_found_if_blank }
		end
	end

	def render
		div(class: 'row') do
			div(class: 'main-content settings-wrapper col-12 col-xl-9 ml-xl-auto') do

				div(class: 'account-info') do

					div(class: 'border-bottom mt-5') do
						h4(class: 'mb-0 pb-3 pt-2 text-gray') { "Dane konta" }
					end

					div(class: 'account-info-body') do

						load_user_main_data
						make_user_copy_if_should

						# name
						div(class: "account-info-row row") do
							div(class: "account-info-header col-12 col-md-4") do
								span(class: "text-bold text-gray") {'Imię'}
								i(class: "account-info-edit ero-pencil text-secondary ml-2 mb-1 f-s-18")
							end.on :click do |e|
								edit_generic_section 'name'
							end

							if !state.edit['name']
								div(class: "account-info-text col-12 col-md-8") do
									span(class: "text-regular text-gray") { CurrentUserStore.current_user.try(:name) }
								end.on :click do |e|
									edit_generic_section 'name'
								end
							end

							if state.edit['name']
								div(class: "account-info-editing col-12 col-md-8") do

									FormGroup(label: '', error: state.errors['name']) do
										input(defaultValue: state.user_copy['name'], type: "text", class: "form-control #{'is-invalid' if (state.errors || {})['name'].present?}", placeholder: "Imię").on :key_up do |e|
											mutate.user_copy['name'] = e.target.value
											mutate.errors['name'] = nil
										end
									end

									button(class: "btn btn-secondary ml-2 btn-sm", type:"submit") do
										"Zapisz"
									end.on(:click) do |e|
										e.prevent_default
										save_main_data 'name'
									end

									button(class: "btn btn-outline-primary btn-outline-cancel text-gray ml-2 btn-sm") do
										"Anuluj"
									end.on :click do |e|
										edit_generic_section 'name'
									end
								end
							end
						end

						# birth year
						div(class: "account-info-row row") do
							div(class: "account-info-header col-12 col-md-4") do
								span(class: "text-bold text-gray") {'Rok urodzenia'}
								i(class: "account-info-edit ero-pencil text-secondary ml-2 mb-1 f-s-18")
							end.on :click do |e|
								edit_generic_section 'birth_year'
							end

							if !state.edit['birth_year']
								div(class: "account-info-text col-12 col-md-8") do
									span(class: "text-regular text-gray") { CurrentUserStore.current_user.try(:birth_year).to_s }
								end.on :click do |e|
									edit_generic_section 'birth_year'
								end
							end

							if state.edit['birth_year']
								div(class: "account-info-editing col-12 col-md-8") do

						      FormGroup(label: "Rok urodzenia", error: state.errors['birth_year']) do
						        Select(placeholder: "Rok urodzenia", clearable: false, maxHeight: "h-300",backspaceRemoves: false, deleteRemoves: false, options: birth_dates.map{|year| {"value": year.to_i, "label": year.to_i} }, selection: state.user_copy['birth_year'].try(:to_i), className: "form-control #{'is-invalid' if (state.errors || {})['birth_year'].present?}").on :change do |e|
						          mutate.user_copy['birth_year'] = e.to_n || nil
						          mutate.errors['birth_year'] = nil
						        end
									end

									button(class: "btn btn-secondary ml-2 btn-sm", type:"submit") do
										"Zapisz"
									end.on(:click) do |e|
										e.prevent_default
										save_main_data 'birth_year'
									end

									button(class: "btn btn-outline-primary btn-outline-cancel text-gray ml-2 btn-sm") do
										"Anuluj"
									end.on :click do |e|
										edit_generic_section 'birth_year'
									end
								end
							end
						end

						# name
						div(class: "account-info-row row") do
							div(class: "account-info-header col-12 col-md-4") do
								span(class: "text-bold text-gray") {'Imię drugiej osoby'}
								i(class: "account-info-edit ero-pencil text-secondary ml-2 mb-1 f-s-18")
							end.on :click do |e|
								edit_generic_section 'name_second_person'
							end

							if !state.edit['name_second_person']
								div(class: "account-info-text col-12 col-md-8") do
									span(class: "text-regular text-gray") { CurrentUserStore.current_user.try(:name_second_person) }
								end.on :click do |e|
									edit_generic_section 'name_second_person'
								end
							end

							if state.edit['name_second_person']
								div(class: "account-info-editing col-12 col-md-8") do

									FormGroup(label: '', error: state.errors['name_second_person']) do
										input(defaultValue: state.user_copy['name_second_person'], type: "text", class: "form-control #{'is-invalid' if (state.errors || {})['name_second_person'].present?}", placeholder: "Imię drugiej osoby").on :key_up do |e|
											mutate.user_copy['name_second_person'] = e.target.value
											mutate.errors['name_second_person'] = nil
										end
									end

									button(class: "btn btn-secondary ml-2 btn-sm", type:"submit") do
										"Zapisz"
									end.on(:click) do |e|
										e.prevent_default
										save_main_data 'name_second_person'
									end

									button(class: "btn btn-outline-primary btn-outline-cancel text-gray ml-2 btn-sm") do
										"Anuluj"
									end.on :click do |e|
										edit_generic_section 'name_second_person'
									end
								end
							end
						end if (state.user_copy['kind'].present? && !['woman', 'man', 'tgsv'].include?(state.user_copy['kind']))

						# birth year
						div(class: "account-info-row row") do
							div(class: "account-info-header col-12 col-md-4") do
								span(class: "text-bold text-gray") {'Rok urodzenia drugiej osoby'}
								i(class: "account-info-edit ero-pencil text-secondary ml-2 mb-1 f-s-18")
							end.on :click do |e|
								edit_generic_section 'birth_year_second_person'
							end

							if !state.edit['birth_year_second_person']
								div(class: "account-info-text col-12 col-md-8") do
									span(class: "text-regular text-gray") { CurrentUserStore.current_user.try(:birth_year_second_person).to_s }
								end.on :click do |e|
									edit_generic_section 'birth_year_second_person'
								end
							end

							if state.edit['birth_year_second_person']
								div(class: "account-info-editing col-12 col-md-8") do

						      FormGroup(label: "Rok urodzenia", error: state.errors['birth_year_second_person']) do
						        Select(placeholder: "Rok urodzenia", clearable: false, maxHeight: "h-300",backspaceRemoves: false, deleteRemoves: false, options: birth_dates.map{|year| {"value": year.to_i, "label": year.to_i} }, selection: state.user_copy['birth_year_second_person'].try(:to_i), className: "form-control #{'is-invalid' if (state.errors || {})['birth_year_second_person'].present?}").on :change do |e|
						          mutate.user_copy['birth_year_second_person'] = e.to_n || nil
						          mutate.errors['birth_year_second_person'] = nil
						        end
									end

									button(class: "btn btn-secondary ml-2 btn-sm", type:"submit") do
										"Zapisz"
									end.on(:click) do |e|
										e.prevent_default
										save_main_data 'birth_year_second_person'
									end

									button(class: "btn btn-outline-primary btn-outline-cancel text-gray ml-2 btn-sm") do
										"Anuluj"
									end.on :click do |e|
										edit_generic_section 'birth_year_second_person'
									end
								end
							end
						end if (state.user_copy['kind'].present? && !['woman', 'man', 'tgsv'].include?(state.user_copy['kind']))

						# city
						div(class: "account-info-row row") do
							div(class: "account-info-header col-12 col-md-4") do
								span(class: "text-bold text-gray") {'Miejscowość'}
								i(class: "account-info-edit ero-pencil text-secondary ml-2 mb-1 f-s-18")
							end.on :click do |e|
								edit_generic_section 'city'
							end

							if !state.edit['city']
								div(class: "account-info-text col-12 col-md-8") do
									span(class: "text-regular text-gray") { CurrentUserStore.current_user.try(:city) }
								end.on :click do |e|
									edit_generic_section 'city'
								end
							end

							if state.edit['city']
								div(class: "account-info-editing col-12 col-md-8") do

									FormGroup(label: "Miejscowość", error: state.errors['city']) do
										GooglePlacesAutocomplete(
											inputProps: { value: state.user_copy['city'], onChange: proc{ |e| city_changed(e)} , placeholder: 'Miejscowość'}.to_n,
											options: MAP_OPTIONS.to_n,
											googleLogo: false,
											classNames: state.errors['city'].present? ? INVALID_CSS_CLASSES.to_n : CSS_CLASSES.to_n,
											onSelect: proc{ |e| city_selected(e)}
										)
									end

									button(class: "btn btn-secondary ml-2 btn-sm", type:"submit") do
										"Zapisz"
									end.on(:click) do |e|
										e.prevent_default
										save_main_data 'city'
									end

									button(class: "btn btn-outline-primary btn-outline-cancel text-gray ml-2 btn-sm") do
										"Anuluj"
									end.on :click do |e|
										edit_generic_section 'city'
									end
								end
							end
						end

						# email
						BlockUi(tag: "div", blocking: state.blocking, class: 'account-info-row row') do
							div(class: "account-info-header col-12 col-md-4 align-items-start") do
								span(class: "text-bold text-gray") {'Adres e-mail'}
								i(class: "account-info-edit ero-pencil text-secondary ml-2 mb-1 f-s-18")
							end.on :click do |e|
								edit_generic_section 'email'
							end

							if !state.edit['email']
								div(class: "account-info-text col-12 col-md-8") do
									span(class: "text-regular text-gray") { CurrentUserStore.current_user.try(:email) }
								end.on :click do |e|
									edit_generic_section 'email'
								end
							end

							if state.edit['email']
								div(class: "account-info-editing col-12 col-md-8") do

									div(class: "row") do
										div(class: "multiple-fields-holder col-12") do
											FormGroup(label: "Nowy email", error: state.errors['new_email']) do
												input(value: state.user_copy['email'], type: "text", class: "form-control #{'is-invalid' if (state.errors || {})['new_email'].present?}", placeholder: "Nowy email").on :change do |e|
													mutate.user_copy['email'] = e.target.value
													mutate.errors['new_email'] = nil
												end
											end
										end

										div(class: "multiple-fields-holder col-12 mt-2") do
											FormGroup(label: "Aktulane hasło", error: state.errors['password']) do
												input(value: state.password, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['password'].present?}", placeholder: "Aktualne hasło").on :change do |e|
													mutate.password e.target.value
													mutate.errors['password'] = nil
												end
											end

											button(class: "btn btn-secondary ml-2 mt-2 mt-md-0 btn-sm", type:"submit") do
												"Zapisz"
											end.on(:click) do |e|
												e.prevent_default
												save_new_email
											end

											button(class: "btn btn-outline-primary btn-outline-cancel text-gray ml-2 mt-2 mt-md-0 btn-sm") do
												"Anuluj"
											end.on :click do |e|
												edit_generic_section 'email'
											end
										end
									end
								end
							end
						end

						# password
						BlockUi(tag: "div", blocking: state.blocking, class: 'account-info-row row') do
							div(class: "account-info-header col-12 col-md-4 align-items-start") do
								span(class: "text-bold text-gray") {'Hasło'}
								i(class: "account-info-edit ero-pencil text-secondary ml-2 mb-1 f-s-18")
							end.on :click do |e|
								edit_generic_section 'password'
							end

							if !state.edit['password']
								div(class: "account-info-text col-12 col-md-8") do
									span(class: "text-regular text-gray") {'******'}
								end.on :click do |e|
									edit_generic_section 'password'
								end
							end

							if state.edit['password']
								div(class: "account-info-editing col-12 col-md-8") do

									div(class: "row") do
										div(class: "multiple-fields-holder col-12") do
											FormGroup(label: "Nowe hasło", error: state.errors['new_password']) do
												input(value: state.new_password, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['new_password'].present?}", placeholder: "Nowe hasło").on :change do |e|
													mutate.new_password e.target.value
													mutate.errors['new_password'] = nil
												end
											end
										end

										div(class: "multiple-fields-holder col-12 mt-2") do
											FormGroup(label: "Powtórz nowe hasło", error: state.errors['new_password_confirmation']) do
												input(value: state.new_password_confirmation, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['new_password_confirmation'].present?}", placeholder: "Powtórz nowe hasło").on :change do |e|
													mutate.new_password_confirmation e.target.value
													mutate.errors['new_password_confirmation'] = nil
												end
											end
										end

										div(class: "multiple-fields-holder col-12 mt-2") do
											FormGroup(label: "Aktualne hasło", error: state.errors['old_password']) do
												input(value: state.old_password, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['old_password'].present?}", placeholder: "Twoje obecne hasło").on :change do |e|
													mutate.old_password e.target.value
													mutate.errors['old_password'] = nil
												end
											end

											button(class: "btn btn-secondary ml-2 mt-2 mt-md-0 btn-sm", type:"submit") do
												"Zapisz"
											end.on(:click) do |e|
												e.prevent_default
												save_new_password
											end

											button(class: "btn btn-outline-primary btn-outline-cancel text-gray ml-2 mt-2 mt-md-0 btn-sm") do
												"Anuluj"
											end.on :click do |e|
												edit_generic_section 'password'
											end
										end
									end
								end
							end
						end

						# pin
						div(class: "account-info-row row") do
							div(class: "account-info-header col-12 col-md-4 align-items-start") do
								span(class: "text-bold text-gray") {'PIN'}
								i(class: "account-info-edit ero-pencil text-secondary ml-2 mb-1 f-s-18")
							end.on :click do |e|
								edit_generic_section 'pin'
							end

							if !state.edit['pin']
								div(class: "account-info-text col-12 col-md-8") do
									span(class: "text-regular text-gray") {'****'}
								end.on :click do |e|
									edit_generic_section 'pin'
								end
							end

							if state.edit['pin']
								div(class: "account-info-editing col-12 col-md-8") do

									div(class: "row") do
										div(class: "multiple-fields-holder col-12") do
											FormGroup(label: "Nowy PIN", error: state.errors['new_pin']) do
												input(value: state.new_pin, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['new_pin'].present?}", placeholder: "Nowy PIN").on :change do |e|
													mutate.new_pin e.target.value
													mutate.errors['new_pin'] = nil
												end
											end
										end

										div(class: "multiple-fields-holder col-12 mt-2") do
											FormGroup(label: "Powtórz nowy PIN", error: state.errors['new_pin_confirmation']) do
												input(value: state.new_pin_confirmation, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['new_pin_confirmation'].present?}", placeholder: "Powtórz nowy PIN").on :change do |e|
													mutate.new_pin_confirmation e.target.value
													mutate.errors['new_pin_confirmation'] = nil
												end
											end
										end

										div(class: "multiple-fields-holder col-12 mt-2") do
											FormGroup(label: "Aktualny PIN", error: state.errors['old_pin']) do
												input(value: state.old_pin, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['old_pin'].present?}", placeholder: "Aktualny PIN").on :change do |e|
													mutate.old_pin e.target.value
													mutate.errors['old_pin'] = nil
												end
											end

											button(class: "btn btn-secondary ml-2 mt-2 mt-md-0 btn-sm", type:"submit") do
												"Zapisz"
											end.on(:click) do |e|
												e.prevent_default
												save_new_pin
											end

											button(class: "btn btn-outline-primary btn-outline-cancel text-gray ml-2 mt-2 mt-md-0 btn-sm") do
												"Anuluj"
											end.on :click do |e|
												edit_generic_section 'pin'
											end
										end
									end
								end
							end
						end
					end
				end

				# if state.edit_account_info
				# 	div(class: 'd-flex justify-content-center mt-5') do
				# 		button(class: 'btn btn-cons btn-secondary mr-2', type: "button") do
				# 			'Potwierdź'
				# 		end.on(:click) do |e|
				# 			e.prevent_default
				# 			save_main_data
				# 		end

				# 		button(class: 'btn btn-outline-primary btn-cons btn-outline-cancel text-gray', type: "button") do
				# 			'Anuluj'
				# 		end.on(:click) do |e|
				# 			mutate.edit_account_info false
				# 		end
				# 	end
				# end

				div(class: 'settings') do

					div(class: 'border-bottom mt-5 mb-4') do
						h4(class: 'mb-3 text-gray') { 'Prywatność' }
					end
					div(class: 'settings-body') do
						[
							{attr: 'show_visits',  text: 'Osoby będą widziały Twoje odwiedziny'  },
							{attr: 'show_age',     text: 'Osoby będą widziały ile masz lat'  },
							# {title: 'Data logowania',   attr: 'show_date',    text: 'Ostatnia data logowania będzie widoczna w Twoim profilu'  },
							{attr: 'show_groups',  text: 'Osoby będą widziały do jakich grup należysz'  },
							{attr: 'show_gallery', text: 'Osoby będą widziały że masz galerię prywatną'  },
							{attr: 'show_online',  text:  'Osoby będą widziały Twoją obecność na portalu' },
							{attr: 'show_blurred',  text:  'Pokazuj rozmyte zdjęcia w galerii prywatnej' }
						].each do |item|
							div(class: 'row mb-3') do
								div(class: 'col-12 col-md-12 d-flex align-items-center') do

									label(class: 'form-check-label big-round-label') do
										input(class: 'form-check-input', type: "checkbox", checked: state.user.privacy_settings[item['attr']])
										.on(:change) do |e|
											mutate.user['privacy_settings'][item['attr']] = e.target.checked
											SaveUserSettings.run({user_id: state.user.id, attr: 'privacy_settings', obj: state.user['privacy_settings']})
										end
										span
									end

									div(class: 'settings-text text-gray text-book ml-3') { item['text'] }
								end
							end
						end

					end
				end

				div(class: 'notifications') do
					div(class: 'border-bottom mt-5 mb-4') do
						h4(class: 'mb-3 text-gray') { "Powiadomienia" }
					end
					div(class: 'notifications-body') do
						div(class: 'row') do
							div(class: 'col-12 col-md-7') do

								div(class: 'row mb-4') do
									div(class: 'col-5 col-md-6')
									div(class: 'col-3 col-md-2 text-regular text-gray text-left text-md-center') do
										span { 'Email' }
									end
									div(class: 'col-4 col-md-4 text-regular text-gray text-center') do
										span { 'Przeglądarka' }
									end
								end

								[
									{ title: 'Wiadomości',         attr: 'on_message' },
									{ title: 'Dopasowania',        attr: 'on_fit' },
									{ title: 'Lubią Cię',          attr: 'on_like' },
									{ title: 'Goście',             attr: 'on_guest' },
									{ title: 'Inne powiadomienia', attr: 'on_other' }
								].each do |item|
									div(class: 'row mb-2') do
										div(class: 'col-5 col-md-6 d-flex align-items-center') do
											span { item['title'] }
										end

										div(class: 'col-3 col-md-2') do
											div(class: 'form-group d-flex justify-content-left justify-content-md-center mb-0') do
												div(class: 'form-check form-check-inline mb-0') do
													label(class: 'form-check-label big-round-label') do
														input(class: 'form-check-input', type: "checkbox", checked: state.user.notification_settings[item['attr']]['email'])
														.on(:change) do |e|
															mutate.user['notification_settings'][item['attr']]['email'] = e.target.checked
															SaveUserSettings.run({user_id: state.user.id, attr: 'notification_settings', obj: state.user['notification_settings']})
														end
														span
													end
												end
											end
										end

										div(class: 'col-4 col-md-4') do
											div(class: 'form-group d-flex justify-content-center mb-0') do
												div(class: 'form-check form-check-inline mb-0') do
													label(class: 'form-check-label big-round-label') do
														input(class: 'form-check-input', type: "checkbox", checked: state.user.notification_settings[item['attr']]['browser'])
														.on(:change) do |e|
															mutate.user['notification_settings'][item['attr']]['browser'] = e.target.checked
															SaveUserSettings.run({user_id: state.user.id, attr: 'notification_settings', obj: state.user['notification_settings']})
														end
														span
													end
												end
											end
										end
									end
								end

								div(class: 'row mb-2') do
									div(class: 'col-5 col-md-6 d-flex align-items-center') do
										span { 'Dźwięki powiadomień' }
									end

									div(class: 'col-3 col-md-2') do
									end

									div(class: 'col-4 col-md-4') do
										div(class: 'form-group d-flex justify-content-center mb-0') do
											div(class: 'form-check form-check-inline mb-0') do
												label(class: 'form-check-label big-round-label') do
													input(class: 'form-check-input', type: "checkbox", checked: state.user.notification_settings['enable_sound'])
													.on(:change) do |e|
														mutate.user['notification_settings']['enable_sound'] = e.target.checked
														SaveUserSettings.run({user_id: state.user.id, attr: 'notification_settings', obj: state.user['notification_settings']})
													end
													span
												end
											end
										end
									end
								end

							end
						end
					end
				end
				div(class: "row mt-5") do
					div(class: "col-12") do
						button(class: 'btn btn-link btn-accout-delete mr-2 pl-0', type: "button") do
							'Usuń konto'
						end.on(:click) do |e|
							e.prevent_default
							e.stop_propagation
							open_delete_user_modal
						end
					end
				end
			end
		end
	end

	def not_found_if_blank
		mutate.user CurrentUserStore.current_user
		history.replace('/profile-not-found') unless state.user.present?
	end

	def birth_dates
		((Time.now - 60.years).year..(Time.now - 18.years).year).to_a.reverse
	end

	def city_changed(val)
		mutate.user_copy['city'] = val
		mutate.user_copy['lon'] = nil
		mutate.user_copy['lat'] = nil
	end

	def city_selected(val)
		if React::IsomorphicHelpers.on_opal_client?
			%x{
				window.GeocodeByAddress(#{val}).then(function(results) {
					var short_name = results[0]['address_components'][0]['short_name']
					var bounds = {
						a: {
							b: results[0]['geometry']['bounds']['b']['b'],
							f: results[0]['geometry']['bounds']['b']['f']
						},
						b: {
							b: results[0]['geometry']['bounds']['f']['b'],
							f: results[0]['geometry']['bounds']['f']['f']
						}
					}
					var location = {
						lat: results[0]['geometry']['location']['lat'](),
						lng: results[0]['geometry']['location']['lng']()
					}

					#{handle_geocode_response(`short_name`, `bounds`, `location`)}
				});
			}
		end
	end

	def handle_geocode_response short_name, bounds, location
		mutate.user_copy['city'] = short_name
		mutate.user_copy['lon'] = Hash.new(location)[:lng]
		mutate.user_copy['lat'] = Hash.new(location)[:lat]
	end

	def load_user_main_data
		[
			state.user.kind,
			state.user.name,
			state.user.birth_year,
			state.user.name_second_person,
			state.user.birth_year_second_person,
			state.user.city,
			state.user.lon,
			state.user.lat
		]
	end

	def make_user_copy_if_should
		if state.user_copy.blank? && state.user.present? && state.user.kind.loaded? && state.user.name.loaded? && state.user.birth_year.loaded? && state.user.name_second_person.loaded? && state.user.birth_year_second_person.loaded? && state.user.city.loaded? && state.user.lon.loaded? && state.user.lat.loaded?
			mutate.user_copy({
				kind: state.user.kind,
				name: state.user.name,
				birth_year: state.user.birth_year,
				name_second_person: state.user.name_second_person,
				birth_year_second_person: state.user.birth_year_second_person,
				city: state.user.city,
				lon: state.user.lon,
				lat: state.user.lat,
				email: state.user.email
			})
		end
	end

	def open_delete_user_modal
		ModalsService.open_modal('DeleteUserModal',{user_id: CurrentUserStore.current_user.id})
	end

	def edit_generic_section section_name
		mutate.edit["#{section_name}"] = !state.edit["#{section_name}"]
		mutate.user_copy["#{section_name}"] = state.user["#{section_name}"]
	end

	def save_new_email
		mutate.blocking true
		ProcessUserEmailChange.run(
			password: state.password,
			new_email: state.user_copy['email']
		).then do |response|
			mutate.blocking false
			mutate.errors {}
			mutate.password ''
			mutate.new_email ''
			`toast.dismiss(); toast.success('Zmiana adresu zakończona powodzeniem', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
			edit_generic_section 'email'
		end.fail do |e|
			if e.is_a?(Hyperloop::Operation::ValidationException)
				`toast.error('Formularz zawiera błedy.')`
				mutate.errors e.errors.message
			elsif e.is_a?(Exception)
				`toast.error('Wystąpił błąd! Upewnij się czy poprawnie wpisałeś swoje hasło.')`
			end
			mutate.blocking false
		end
	end

	def save_new_password
		mutate.blocking true
		ProcessUserPasswordChange.run(
			old_password: state.old_password,
			new_password: state.new_password,
			new_password_confirmation: state.new_password_confirmation
		).then do |response|
			mutate.blocking false
			mutate.errors {}
			mutate.old_password ''
			mutate.new_password ''
			mutate.new_password_confirmation ''
			`toast.dismiss(); toast.success('Zmiana hasła zakończona powodzeniem', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
			edit_generic_section 'password'
		end.fail do |e|
			if e.is_a?(Hyperloop::Operation::ValidationException)
				`toast.error('Formularz zawiera błedy.')`
				mutate.errors e.errors.message
			elsif e.is_a?(Exception)
				`toast.error('Wystąpił błąd! Upewnij się czy obecne hasło jest poprawne.')`
			end
			mutate.blocking false
		end
	end

	def save_new_pin
		mutate.blocking true
		ProcessUserPinChange.run(
			old_pin: state.old_pin,
			new_pin: state.new_pin,
			new_pin_confirmation: state.new_pin_confirmation
		).then do |response|
			mutate.blocking false
			mutate.old_pin ''
			mutate.new_pin ''
			mutate.new_pin_confirmation ''
			mutate.errors {}
			`toast.dismiss(); toast.success('Zmiana PINu zakończona powodzeniem', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
			edit_generic_section 'pin'
		end.fail do |e|
			if e.is_a?(Hyperloop::Operation::ValidationException)
				`toast.error('Formularz zawiera błedy.')`
				mutate.errors e.errors.message
			elsif e.is_a?(Exception)
				`toast.error('Wystąpił błąd! Upewnij się czy twój stary PIN jest poprawny.')`
			end
			mutate.blocking false
		end
	end

	def save_main_data section_name
		mutate.blocking true
		puts "state.user_copy['name'] #{state.user_copy['name']}"
		ProcessUserMainDataChange.run(
			kind: state.user_copy['kind'],
			name: state.user_copy['name'],
			birth_year: state.user_copy['birth_year'],
			name_second_person: state.user_copy['name_second_person'],
			birth_year_second_person: state.user_copy['birth_year_second_person'],
			city: state.user_copy['city'],
			lon: state.user_copy['lon'],
			lat: state.user_copy['lat'],

		).then do |response|
			mutate.blocking false
			mutate.errors {}
			`toast.dismiss(); toast.success('Udało się zmienić informacje ogólne', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`

			mutate.edit["#{section_name}"] = !state.edit["#{section_name}"]

		end.fail do |e|
			if e.is_a?(Hyperloop::Operation::ValidationException)
				puts "error #{e.errors}"
				`toast.error('Formularz zawiera błedy.')`
				mutate.errors e.errors.message
			elsif e.is_a?(Exception)
				`toast.error('Wystąpił błąd! Upewnij się czy poprawnie wpisałeś dane podstawowe.')`
			end
			mutate.blocking false
		end
	end
end