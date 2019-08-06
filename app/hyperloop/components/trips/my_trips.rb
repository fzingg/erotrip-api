
class MyTrips < Hyperloop::Router::Component

  TRIP_SORT_OPTIONS = [
		{ value: 'created_at desc',     label: 'Najnowsze'    },
		{ value: 'upcoming',            label: 'Nadchodzące' },
    # { value: 'created_at asc',      label: 'Najstarsze'   }
    # { value: 'online',             label: 'Teraz online'  },
    # { value: 'last_seen',         label: 'Ostatnio byli' }
  ]

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
      ErotripUsersSearchEncoder.handle_decode(hash, PARSE_SCOPE)
    end)
  }

  state total: 0
  state current_page: 1
  state per_page: 10

  state search_params: {}
  state history_listener: nil
  state search_params_synced: true


  before_mount do
    load_resources
    # mutate.search_params default_search_params
    # if location.search.present?
    #   puts "> APPLYING SEARCH"

    #   # decoded = ErotripSearchParser.decode(location.search, DECODER_OPTIONS)
    #   # if decoded["page"] && decoded["page"].to_i > 0
    #   #   mutate.current_page decoded["page"].to_i
    #   # end
    #   # mutate.search_params decoded
    #   # mutate.search_params_synced false
    #   decoded = ErotripSearchParser.decode(location.search, DECODER_OPTIONS)
    #   if decoded["page"] && decoded["page"].to_i > 0
    #     mutate.current_page decoded["page"].to_i
    #   end
    #   proper_params = default_search_params
    #   decoded.keys.each do |key|
    #     proper_params[key] = decoded[key]
    #   end
    #   if proper_params['sorts'] != 'upcoming'
    #     proper_params['upcoming'] = nil
    #   end
    #   mutate.search_params proper_params
    #   mutate.search_params_synced false
    # else
    #   apply_defaults
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
      apply_defaults
      mutate.search_params_synced false if always_sync
    end
  end

  def apply_defaults
    puts "> APPLYING DEFAULTS"

    mutate.search_params default_search_params
    mutate.search_params_synced true # defaults already synced
    # AppRouter.replace(PATH, ErotripSearchParser.encode(default_search_params, ENCODER_OPTIONS))
  end

  after_mount do
    mutate.history_listener (history.listen do |location, action|
      on_location_change(location, action)
    end)
  end

  # before_unmount do
  #   state.history_listener.call() if state.history_listener.present?
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
			upcoming:               true,
      sorts:                  TRIP_SORT_OPTIONS[0][:value]
    }
  end

  def render
    trips_scope = Trip.ransacked(prepare_search_params(state.search_params, CurrentUserStore.current_user_id))

    div(class: 'row') do
      div(class: 'col-12 col-xl-9 ml-xl-auto main-content') do

        # HotlineCarousel()

        # TripsSearchBox(trips_count: trips_scope.count, search: false).on :change do |e|
        #   search_changed e.to_n
        # end


        # TripsSearchBox(
        #   trips_count: trips_scope.count,
        #   current_user: CurrentUserStore.current_user,
        #   search_params: default_search_params,
        #   sort_options: TRIP_SORT_OPTIONS,
        #   ransack_context: 'user_',
        #   rows_count_one: "wycieczka",
        #   rows_count_few: "wycieczki",
        #   rows_count_many: "wycieczek",
        #   ero_path_name: 'Moje przejazdy'
        # ).on :change do |e|
        #   search_changed e.to_n
        # end

        TripsSearchBox(
          trips_count:  state.search_params.keys.try(:size) > 0 && trips_scope.loaded? ? trips_scope.count : nil,
          search_params: default_search_params,
          sort_options: TRIP_SORT_OPTIONS,
          ero_path_name: 'Moje przejazdy',
          ransack_context: PARSE_SCOPE,
          sync_search_params: !state.search_params_synced,
          new_search_params: state.search_params,
          on_search_params_sync: proc{ search_params_synced }
        ).on :change do |e|
          search_changed e.to_n
        end

        if state.search_params.keys.size > 0 && trips_scope.loaded?

          if trips_scope.size > 0
            trips_scope.limit(state.per_page).offset((state.current_page - 1) * state.per_page).each do |trip|

              TripSingle(trip: trip)
            end

          elsif trips_scope.size == 0
            div(class: "placeholder") do
              i(class: "ero-hotline f-s-30 text-primary")
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

  def search_changed options
    # AppRouter.push(PATH, ErotripSearchParser.encode(options[:terms], ENCODER_OPTIONS))
    # mutate.current_page 1
    # mutate.search_params options[:terms]
    # # end
    mutate.current_page 1
    mutate.search_params options[:terms]
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


  def page_changed page
    # terms = state.search_params
    # terms[:page] = page
    # AppRouter.push(PATH, ErotripSearchParser.encode(terms, ENCODER_OPTIONS))
    # mutate.current_page page

    terms = state.search_params
    terms[:page] = page
    mutate.current_page page
    history.push(location.pathname, {terms: state.search_params, page: state.current_page}.to_json)
  end

  def prepare_search_params params, current_user_id
    new_params = params.dup
    if (new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] && (Time.now.year - new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] >= 50))
      new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] = nil
    end

    # if new_params["city_eq"].present?
    #   if new_params["destinations_within"][0] > 0
    #     new_params["city_eq"] = nil
    #     new_params["destinations_in_bounds"] = nil
    #   else
    #     new_params["destinations_within"] = [0, nil]
    #   end
    # else
    #   new_params["destinations_in_bounds"] = nil
    #   new_params["destinations_within"] = [0, nil]
    # end
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

    if new_params['sorts'] == 'mine' || new_params['sorts'].try(:[], 0) == 'mine'
      new_params['sorts'] = 'created_at desc'
      new_params['upcoming'] = false
      new_params['user_id_eq'] = CurrentUserStore.current_user.try(:id)
    elsif new_params['sorts'] == 'upcoming' || new_params['sorts'].try(:[], 0) == 'upcoming'
      new_params["sorts"] = 'arrival_time asc'
      new_params["upcoming"] = true
      new_params['user_id_eq'] = nil
    else
      new_params["upcoming"] = false
      new_params['user_id_eq'] = nil
    end

    new_params["user_id_eq"] = current_user_id

    puts "PERPARED PARAMS: #{new_params}"
    puts "ORIGINAL PARAMS: #{params}"
    new_params
  end

end