class NewTripsIndex < Hyperloop::Router::Component

	TRIP_SORT_OPTIONS = [
		{ value: 'created_at desc',     label: 'Najnowsze' },
		{ value: 'upcoming',            label: 'Nadchodzące' },
		{ value: 'mine',                label: 'Moje', auth: true }
		# { value: 'last_seen',         label: 'Ostatnio byli' }
	]

	PATH = 'new-trips'

	PARSE_SCOPE = "user_"

	ENCODER_OPTIONS = {
		before_encode: (proc do |data|
			ErotripUsersSearchEncoder.handle_encode(data, PARSE_SCOPE)
		end)
	}

	DECODER_OPTIONS = {
		parse: {
			numeric_or_nil: ["page", "#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq", "#{PARSE_SCOPE}id_eq", "#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_lteq", "#{PARSE_SCOPE}height_gteq", "#{PARSE_SCOPE}height_lteq"],
			boolean_or_nil: ["active_recently", "upcoming", "is_smoker_eq", "is_drinker_eq", "is_verified_eq", "online_now", "online_recently", "with_photos", "without_photos"].map{ |key| "#{PARSE_SCOPE}#{key}" },
			string_or_empty_string: ["city_eq", "height"],
			array_or_empty_array: ["body_in", "looking_for", "kind_in", "interests_id_in"].map{ |key| "#{PARSE_SCOPE}#{key}" },
			array_or_nil: ["destinations_in_bounds"],
			array_values_to_int: ["#{PARSE_SCOPE}interests_id_in"]
		},
		after_decode: (proc do |hash|
			# Tutaj zamiast logiki destinations_within powinna byc logika destinations_within
			ErotripUsersSearchEncoder.handle_decode(hash, PARSE_SCOPE)
		end)
	}

	state total: 0
	state current_page: 1
	state per_page: 10

	state search_params: {}

	state created_after: nil

	state history_listener: nil
	state search_params_synced: true

	state other_users_location_not_eq_scope: nil
  state :user

	before_mount do


    if CurrentUserStore.current_user_id
      User.find(CurrentUserStore.current_user_id).load(:last_trips_visit_at, :lon, :lat).then do |data|
        mutate.user User.find(CurrentUserStore.current_user_id)
      end
    else
      mutate.user nil
    end

    load_resources

    if state.user.present?
      mutate.other_users_location_not_eq_scope([
        state.user.try(:id),
        state.user.try(:lon),
        state.user.try(:lat)
      ])
    end

    # if CurrentUserStore.current_user_id.present?
    #   CurrentUserStore.on_current_user_load(proc do
    #     mutate.other_users_location_not_eq_scope([
    #       CurrentUserStore.current_user.try(:id),
    #       CurrentUserStore.current_user.try(:lon),
    #       CurrentUserStore.current_user.try(:lat)
    #     ])
    #   end)
    # end
  end


  def load_resources always_sync=false
    if location.state.present? && location.state.index('terms').present?
      locationState = JSON.parse(location.state)
      puts "LOCATION CHANGED!", locationState['terms'].inspect
      mutate.search_params locationState['terms']
      mutate.current_page locationState['page'].to_i > 0 ? locationState['page'].to_i : 1
      mutate.search_params_synced false
    else
      mutate.search_params default_search_params

      if always_sync
        mutate.search_params_synced false
      else
        mutate.search_params_synced true
      end
    end

		if state.user.try(:last_trips_visit_at)
			mutate.created_after CurrentUserStore.current_user.last_trips_visit_at.try(:to_s)
		else
			CurrentUserStore.on_current_user_load proc { user_loaded }
		end

	end

  after_mount do
		UpdateUserVisits.run(visit: 'trips').then do |response|
			# handle response
		end
		.fail do |e|
			# handle errors
		end

		mutate.history_listener (history.listen do |location, action|
			on_location_change(location, action)
		end)
	end

	# before_unmount do
	# 	state.history_listener.call() if state.history_listener.present?
	# end

	# def apply_defaults
	# 	puts "> APPLYING DEFAULTS"

	# 	mutate.search_params default_search_params
	# 	mutate.search_params_synced true # defaults already synced
	# 	# AppRouter.replace(PATH, ErotripSearchParser.encode(default_search_params, { destinations_split_within: true, scope: "user_" }))
	# end

	def default_search_params
		{
      destinations_in_bounds: nil,                 # southwest, northeast bounding coordinates eg. [{lon: "", lat: ""}, {lon: "", lat: ""}]
      destinations_within:    [0, nil],            # origin point and range eg. [25, {lon: 19, lat: 52}]
      city_eq:                '',
      user_kind_in:           [],
      user_looking_for:       [],
      user_is_verified_eq:    nil,
      user_is_drinker_eq:     nil,
      user_is_smoker_eq:      nil,
      user_with_photos:       nil,
      user_without_photos:    nil,
      user_birth_year_or_user_birth_year_second_person_lteq:   Time.now.year - 18,
      user_birth_year_or_user_birth_year_second_person_gteq:   Time.now.year - 50,
      user_height_lteq:       nil,
      user_height_gteq:       nil,
      user_body_in:           [],
			user_interests_id_in:   [],
			user_id_eq:             nil,
			upcoming:               nil,
			other_users_location_not_eq:   nil,
      sorts:                        TRIP_SORT_OPTIONS[0][:value]
    }
	end

	def today
    now = Time.now
    Time.new(now.year, now.month, now.day, 0, 0, 0)
	end

	def user_loaded
		Hyperloop::Model.load do
			CurrentUserStore.current_user.last_trips_visit_at
		end.then do |data|
			mutate.created_after CurrentUserStore.current_user.try(:last_trips_visit_at)
		end
	end

	def render
		# sp = state.search_params.dup

		# if state.other_users_location_not_eq_scope.present? && CurrentUserStore.current_user.present?
		# 	sp["other_users_location_not_eq"] = state.other_users_location_not_eq_scope
		# else
		# 	sp["other_users_location_not_eq"] = nil
		# end


		trips_scope = Trip.not_by_user(CurrentUserStore.current_user_id).created_after(state.created_after.to_s).arrival_after((today - 1.month).to_s).ransacked(prepare_search_params(state.search_params, state.other_users_location_not_eq_scope))

		div(class: 'row') do
			div(class: 'col-12 col-xl-9 ml-xl-auto main-content') do

				# HotlineCarousel()

				TripsSearchBox(
				  trips_count: state.search_params.present? && state.search_params.keys.try(:size) > 0 && trips_scope.loaded? ? trips_scope.count : nil,
				  search_params: default_search_params,
				  sort_options: TRIP_SORT_OPTIONS,
				  ero_path_name: 'Nowe przejazdy',
					ransack_context: 'user_',
					show_only_users_with_different_location: true,
					sync_search_params: !state.search_params_synced,
					new_search_params: state.search_params,
					on_search_params_sync: proc{ search_params_synced }
				).on :change do |e|
				  search_changed e.to_n
				end

        # div { "state.search_params.keys.size > 0 #{state.search_params.keys.size > 0}" }
        # div { "trips_scope.loaded? #{trips_scope.loaded?}" }
        # div { "state.search_params['other_users_location_not_eq'].present?, state.search_params['other_users_location_not_eq'] #{state.search_params['other_users_location_not_eq'].present?}, #{state.search_params['other_users_location_not_eq']}" }
        # div { "CurrentUserStore.current_user_id.blank? #{CurrentUserStore.current_user_id.blank?}" }
        # div { "state.search_params.inspect #{state.search_params.inspect}" }
        # div { "state.search_params.keys.join(', ') #{state.search_params.keys.join(', ')}" }

				if state.search_params.present? && state.search_params.keys.size > 0 && trips_scope.loaded?
          # && (state.other_users_location_not_eq_scope.present? || CurrentUserStore.current_user_id.blank?)

          if trips_scope.size > 0
						trips_scope.limit(state.per_page).offset((state.current_page - 1) * state.per_page).each do |trip|
							TripSingle(trip: trip)
						end

          else
            div(class: "placeholder") do
              i(class: "ero-new-trips f-s-30 text-primary")
              span() {'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.'}
            end
          end

          Pagination(page: state.current_page,
            per_page: state.per_page,
            total: trips_scope.count
          ).on :change do |e|
            page_changed e.to_n
          end

				else
					div(class: 'dots-container') do
            div(class: 'animated-dots') do
              span {'.'}
              span {'.'}
              span {'.'}
            end
					end
				end

			end
		end

	end

	# User applied new search
	def search_changed(options)
    mutate.current_page 1
    mutate.search_params options[:terms]
    history.push(location.pathname, {terms: state.search_params, page: state.current_page}.to_json)
	end

	# User changed page
	def page_changed page
    terms = state.search_params
    terms[:page] = page
    mutate.current_page page
    history.push(location.pathname, {terms: state.search_params, page: state.current_page}.to_json)
	end

	def on_location_change(location, action)
		if action == "POP"
      load_resources(true)
		end
	end

	def search_params_synced
		mutate.search_params_synced true
	end

	def prepare_search_params params, other_users_location_not_eq_scope
		new_params = params.dup
		if (new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] && (Time.now.year - new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] >= 50))
			new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] = nil
		end

    if new_params["city_eq"].present?
      if new_params["destinations_within"][0] > 0
        new_params["city_eq"] = nil
        new_params["destinations_in_bounds"] = nil
      else
        new_params["destinations_within"] = [0, nil]
      end
    else
      new_params["destinations_in_bounds"] = nil
      new_params["destinations_within"] = [0, nil]
    end

    if new_params['sorts'] == 'mine'
      new_params['sorts'] = 'created_at desc'
      new_params['upcoming'] = false
      new_params['user_id_eq'] = CurrentUserStore.current_user.try(:id)
    elsif new_params['sorts'] == 'upcoming'
      new_params["sorts"] = ['arrival_time asc']
      new_params["upcoming"] = true
      new_params['user_id_eq'] = nil
    else
      new_params["upcoming"] = false
      new_params['user_id_eq'] = nil
    end


    if other_users_location_not_eq_scope.present? && CurrentUserStore.current_user.present?
      new_params["other_users_location_not_eq"] = other_users_location_not_eq_scope
    else
      new_params["other_users_location_not_eq"] = nil
    end

		new_params
	end

end