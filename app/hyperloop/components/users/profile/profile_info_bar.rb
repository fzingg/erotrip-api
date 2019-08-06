class ProfileInfoBar < Hyperloop::Router::Component
	param user: {}
	param hotline: nil
	param trip: nil
	param current_pathname: ''
	# param onToggleSettings: nil
	state blocking: false
	state wants_to_meet: false
	state settings_visible: false
	state formatted_trip_date: nil
	state formatted_hotline_date: nil
	state set_timeout: nil



	def trigger_formatted_dates_update
		if params.trip.present? && params.trip.arrival_time.present?
			set_formatted_date(params.trip.arrival_time, 'trip')
		end
		if params.hotline.present? && params.hotline.created_at.present?
			set_formatted_date(params.hotline.created_at, 'hotline')
		end
	end

	after_mount do
		trigger_formatted_dates_update
		`var midnightDate = new Date();
		midnightDate.setHours(24,0,0,0);
		var diff = midnightDate.getTime() - (new Date()).getTime();
		var interval = setTimeout(function(){
		#{trigger_formatted_dates_update}
		}, diff + 2500);`
		mutate.set_timeout `interval`
	end


	before_unmount do
		`clearTimeout(#{state.set_timeout})`
		mutate.set_timeout nil
	end


	before_receive_props do |new|
		if new[:trip].present? && new[:trip][:arrival_time].present? && !state.formatted_trip_date.present?
			set_formatted_date(new[:trip][:arrival_time], 'trip')
		end
		if new[:hotline].present? && new[:hotline][:created_at].present? && !state.formatted_hotline_date.present?
			set_formatted_date(new[:hotline][:created_at], 'hotline')
		end
	end

	def get_formatted_date date
		`var newDate = new Date(#{date.to_s})
		var returnedValue = null;
		if (newDate.toDateString() == new Date(new Date().setDate(new Date().getDate() -1 )).toDateString()) {
			returnedValue = { prefix: "Wczoraj, ", datetime: #{date.strftime('%H:%M ')} }
		} else if (new Date().toDateString() === newDate.toDateString()) {
			returnedValue = { prefix: "Dziś, ", datetime: #{date.strftime('%H:%M ')} }
		} else if (new Date().toDateString() === newDate.toDateString()) {
			returnedValue = { prefix: "Dziś, ", datetime: #{date.strftime('%H:%M ')} }
		} else if (newDate.toDateString() == new Date(new Date().setDate(new Date().getDate() +1 )).toDateString()) {
			returnedValue =	{ prefix: "Jutro, ", datetime: #{date.strftime('%H:%M ')} }
		} else {
			returnedValue = { prefix: '', datetime: #{date.strftime('%d')} + ' ' + newDate.toLocaleString('pl-PL', { month: "short" }) + ' ' + #{date.strftime('%Y %H:%M ')} }
		}`
		Native(`returnedValue`)
		end

	def set_formatted_date(date, model)
		x = get_formatted_date date
		hash = { prefix: x[:prefix], datetime: x[:datetime] }
		mutate.formatted_trip_date hash if model == 'trip'
		mutate.formatted_hotline_date hash if model == 'hotline'
	end

	def send_message
		if CurrentUserStore.current_user.blank?
			ModalsService.open_modal('RegistrationModal', { callback: proc { AppRouter.push params.to } })
		else
			mutate.blocking true
			GetRoomUserForContextAndJoin.run({ context_type: 'User', context_id: params.user.try(:id), user_id: params.user.try(:id) })
			.then do |room_user|
				ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static', initial_room_user_id: room_user.try(:id)})
				mutate.blocking false
			end.catch do |e|
				mutate.blocking false
				`toast.error('Nie udało się otworzyć czatu...')`
			end
		end
	end

	def open_messenger_for item, kind
		mutate.blocking true
		GetRoomUserForContextAndJoin.run({ context_type: kind, context_id: item.try(:id) })
		.then do |room_user|
			mutate.blocking false
			# `console.log('we have room_user', room_user.context_id, room_user.try(:id, room_user)`
			ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static', initial_room_user_id: room_user.try(:id), initial_message: 'Hej, chętnie Cię poznam ;)' })
		end.catch do |e|
			mutate.blocking false
			puts "ERROR, #{e.inspect}"
		end
	end

	def render
		div(class: "profile-info-bar streach-me #{'hotline-present' if params.hotline.present? || params.trip.present? } #{'message-button-displayed' if (CurrentUserStore.current_user.blank? || CurrentUserStore.current_user.present? && params.user.present? && CurrentUserStore.current_user_id.loaded? && CurrentUserStore.current_user_id != params.user.try(:id))}") do
			div(class: "patch")

			div(class: "profile-info-bar-inner d-block will-load #{'not-loaded' if !(params.user.present? && params.user.try(:loaded?) && params.user.try(:name).try(:loaded?) && (!params.user.privacy_settings["show_age"] || params.user.try(:birth_year).try(:loaded?)))}") do

				# profile-container
				div(class: "profile-info-wrapper") do

					# profile
					div(class: "user-descriptor-wrapper") do

						if should_display_message_and_want_to_meet_buttons
						WantToMeetButton(user: params.user)
						end

						UserDescriptor(user: params.user, show_status: true, show_verification: true, show_two_lined: false, show_city: true, show_last_sign_in: false)
					end

					# buttons
					div() do
						if should_display_message_and_want_to_meet_buttons

							button(class: "btn btn-secondary btn-lg d-none d-md-flex align-items-center justify-content-center text-medium", type: "button") do
								i(class: 'ero-messages text-white f-s-18 mr-2')
								'Wyślij wiadomość'
							end.on :click do |e|
								send_message
							end
						elsif CurrentUserStore.current_user_id == params.user.try(:id)
							span(class: "btn btn-outline-primary btn-outline-gray icon-only d-none d-md-flex d-link-flex") do
								EroLink(to: "/profile/#{CurrentUserStore.current_user_id}#{params.current_pathname.end_with?('/settings') ? '' : '/settings'}") do
									i(class: "#{params.current_pathname.end_with?('/settings') ? 'ero-user' : 'ero-settings'} text-white f-s-20")
								end
							end
						end
					end
				end

				# buttons displayed on other person profile when no hotlines nor trips present
				if CurrentUserStore.current_user_id != params.user.try(:id) && !params.hotline.present? && !params.trip.present?
					div(class: "profile-no-hotline-mobile-buttons") do
						button(class: "btn btn-secondary btn-lg btn-sm-block d-flex align-items-center justify-content-center text-medium", type: "button") do
							i(class: 'ero-messages text-white f-s-18 mr-3')
							'Wyślij wiadomość'
						end.on :click do |e|
							send_message
						end
					end
				end

				# hotline content container
				if params.hotline.present?

					div(class: "profile-hotline-bar d-flex align-items-start justify-content-start") do
						button(class: 'btn btn-outline-primary btn-outline-gray icon-only mr-2', type: "button") do
							span(class: "exclamation") {'!'}
						end.on(:click) { |e| alert_hotline params.hotline, e }

						div() do
							div(class: 'profile-hotline-bar-time') do
								span(class: 'text-white') { state.formatted_hotline_date.present? ? "#{state.formatted_hotline_date['prefix']}#{state.formatted_hotline_date['datetime']}" : 'Nieznam' }
							end
							p(class: "profile-hotline-bar-text mb-0 mr-3 text-white text-book") { params.hotline.try(:content) }
						end
					end

					button(class: "btn btn-secondary btn-lg btn-sm-block profile-hotline-trips-button d-flex d-md-none", type: "button") do
						i(class: 'ero-messages text-white f-s-18 mr-2')
						'Odpowiedz na hotline'
					end.on :click do |e|
						open_messenger_for params.hotline, 'Hotline'
					end


				# trips content container
				elsif params.trip.present?

					div(class: "profile-hotline-bar d-flex align-items-start justify-content-start") do
						button(class: 'btn btn-outline-primary btn-outline-gray icon-only mr-2', type: "button") do
							span(class: "exclamation") {'!'}
						end.on(:click) { |e| alert_trip params.trip, e }

						div() do
							div(class: 'profile-hotline-bar-time') do
								span(class: 'text-white') do

									if CurrentUserStore.current_user.try(:lon) && CurrentUserStore.current_user.try(:lat) && params.trip.present? && params.trip.through(CurrentUserStore.current_user.try(:lon), CurrentUserStore.current_user.try(:lat))
										span { state.formatted_trip_date.present? ? state.formatted_trip_date["prefix"] : '' }
										# span { "zapytaj o godzinę " }.on(:click) do
										#   open_messenger_for params.trip, 'Trip'
										# end
									else
										span { state.formatted_trip_date.present? ? state.formatted_trip_date["prefix"] : '' }
										span { state.formatted_trip_date.present? ? state.formatted_trip_date["datetime"] : '' }
									end

									span(class: "#{'text-secondary-light' unless has_inter_destinations? && get_destinations.present?}") { get_main_destinations }

									if has_inter_destinations? && get_destinations.present?
										span(style: { whiteSpace: 'nowrap' }) do
											span { " przez" }
											span(class: 'text-secondary-light') { " #{get_destinations}" }
										end
									end

								end
							end
							p(class: "profile-hotline-bar-text mb-0 mr-3 text-white text-book") { params.trip.try(:description) }
						end
					end

					button(class: "btn btn-secondary btn-lg btn-sm-block profile-hotline-trips-button d-flex d-md-none", type: "button") do
						i(class: 'ero-messages text-white f-s-18 mr-2')
						'Odpowiedz na przejazd'
					end.on :click do |e|
						open_messenger_for params.trip, 'Trip'
					end

				end
			end

			div(class: "profile-info-bar-inner-loading #{'d-none' if (params.user.present? && params.user.try(:loaded?) && params.user.try(:name).try(:loaded?) && (!params.user.privacy_settings["show_age"] || params.user.try(:birth_year).try(:loaded?)))}") do
				div(class: 'dots-container pt-0') do
				  div(class: 'animated-dots') do
				    span {'.'}
				    span {'.'}
				    span {'.'}
				  end
				end
			end

			# hotline-trips button
			if params.hotline.present?
				button(class: "btn btn-secondary btn-lg btn-sm-block profile-hotline-trips-button d-none d-md-flex", type: "button") do
					i(class: 'ero-messages text-white f-s-18 mr-2')
					'Odpowiedz na hotline'
				end.on :click do |e|
					open_messenger_for params.hotline, 'Hotline'
				end

			elsif params.trip.present?
				button(class: "btn btn-secondary btn-lg btn-sm-block profile-hotline-trips-button d-none d-md-flex", type: "button") do
					i(class: 'ero-messages text-white f-s-18 mr-2')
					'Odpowiedz na przejazd'
				end.on :click do |e|
					open_messenger_for params.trip, 'Trip'
				end
			end
		end
	end

	def should_display_message_and_want_to_meet_buttons
		if params.user.present? && !params.hotline.present? && !params.trip.present?
			if params.user.try(:id).loaded?
				if params.user.try(:id) != nil
					if CurrentUserStore.current_user_id.present?
						if CurrentUserStore.current_user_id != params.user.try(:id)
							true
						else
							false
						end

					# logged out case
					elsif CurrentUserStore.current_user_id.blank?
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
		else
			false
		end
	end

	def send_message
		if CurrentUserStore.current_user.blank?
			ModalsService.open_modal('RegistrationModal', { callback: proc { AppRouter.push params.to } })
		else
			mutate.blocking true
			GetRoomUserForContextAndJoin.run({ context_type: 'User', context_id: params.user.try(:id), user_id: params.user.try(:id) })
			.then do |room_user|
				ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static', initial_room_user_id: room_user.try(:id)})
				mutate.blocking false
			end.catch do |e|
				mutate.blocking false
				`toast.error('Nie udało się otworzyć czatu...')`
			end
		end
	end

	def open_messenger_for item, kind
		mutate.blocking true
		GetRoomUserForContextAndJoin.run({ context_type: kind, context_id: item.try(:id) })
		.then do |room_user|
			mutate.blocking false
			# `console.log('we have room', room.context_id, room.try(:id, room)`
			ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static', initial_room_user_id: room_user.try(:id), initial_message: 'Hej, chętnie Cię poznam ;)' })
		end.catch do |e|
			mutate.blocking false
			puts "ERROR, #{e.inspect}"
		end
	end

	def alert_hotline hotline, event=nil
		if event
			event.prevent_default
			event.stop_propagation
		end
		ModalsService.open_modal('HotlineAlert', { size_class: 'modal-md', resource_id: hotline.try(:id), resource_type: 'Hotline' })
	end

	def alert_trip trip, event=nil
		if event
			event.prevent_default
			event.stop_propagation
		end
		ModalsService.open_modal('TripAlert', { size_class: 'modal-md', resource_id: trip.try(:id), resource_type: 'Trip' })
	end

	def has_inter_destinations?
		params.trip.try(:destinations).try(:[], 'data').try(:size).try(:>, 2)
	end

	def get_destinations
		a = params.trip.try(:destinations).try(:[], 'data')
		return unless a.is_a? Array
		closest = Hash["city", nil, "distance", nil]
		closest[:city] = ''
		closest[:distance] = nil

		a[1..(a.count - 1)].each do |loc|
			rad_per_deg = Math::PI / 180
			rm = 6371000
			lat1 = loc[:lat]
			lon1 = loc[:lon]
			lat2 = CurrentUserStore.current_user.try(:lat)
			lon2 = CurrentUserStore.current_user.try(:lon)
			unless lat2.nil? || lon2.nil?
				lat1_rad, lat2_rad = lat1 * rad_per_deg, lat2 * rad_per_deg
				lon1_rad, lon2_rad = lon1 * rad_per_deg, lon2 * rad_per_deg
				x = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
				c = 2 * Math::atan2(Math::sqrt(x), Math::sqrt(1 - x))
				distance = rm * c # meters
				if (closest[:city].nil? || closest[:distance].nil? || closest[:distance] > distance)
					closest[:city] = loc[:city]
					closest[:distance] = distance
				end
			end
		end
		return closest[:city] = params.trip.destinations.try(:[], 'data').last["city"] == closest[:city] ? nil : closest[:city]
	end

	def get_main_destinations
		if params.trip.try(:destinations).try(:[], 'data').present?
			a = params.trip.try(:destinations).try(:[], 'data').try(:[], -1)
			a['city'] unless a.is_a? Integer
		else
			''
		end
	end

end