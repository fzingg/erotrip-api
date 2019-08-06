class PeepersIndex < Hyperloop::Router::Component
	VISIT_SORT_OPTIONS = [
    { value: 'created_at desc',     label: 'Najnowsi'    },
		{ value: 'online_now',                  label: 'Teraz online' },      # ransacker
		{ value: 'online_recently',             label: 'Ostatnio byli' }      # ransacker
	]

	PATH = 'peepers'

	PARSE_SCOPE = 'visitor_'

	ENCODER_OPTIONS = {
		before_encode: (proc do |data|
			ErotripUsersSearchEncoder.handle_encode(data, PARSE_SCOPE)
		end)
	}

	DECODER_OPTIONS = {
		parse: {
			numeric_or_nil: ["page", "#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq", "#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_lteq", "#{PARSE_SCOPE}height_gteq", "#{PARSE_SCOPE}height_lteq"],
			boolean_or_nil: ["active_recently", "is_smoker_eq", "is_drinker_eq", "is_verified_eq", "online_now", "online_recently", "with_photos", "without_photos"].map{ |key | "#{PARSE_SCOPE}#{key}" },
			string_or_empty_string: ["#{PARSE_SCOPE}city_eq", "height"],
			array_or_empty_array: ["body_in", "looking_for", "kind_in", "interests_id_in"].map{ |key | "#{PARSE_SCOPE}#{key}" },
			array_or_nil: ["#{PARSE_SCOPE}find_in_bounds"],
			array_values_to_int: ["#{PARSE_SCOPE}interests_id_in"]
		},
		after_decode: (proc do |hash|
			ErotripUsersSearchEncoder.handle_decode(hash, PARSE_SCOPE)
		end)
	}

	state current_page: 1
	state per_page: 20

	state search_params: {}

	state history_listener: nil
	state search_params_synced: true

	before_mount do
    load_resources
  end

  def load_resources always_sync=false
    if location.state.present? && location.state.index('terms').present?
      locationState = JSON.parse(location.state)
      puts "LOCATION CHANGED!", locationState['terms'].inspect
      mutate.search_params locationState['terms']
      mutate.current_page locationState['page'].to_i > 0 ? locationState['page'].to_i : 1
      mutate.search_params_synced false
		else
			puts "> APPLYING DEFAULTS"

			mutate.search_params default_search_params
      if always_sync
        mutate.search_params_synced false
      else
        mutate.search_params_synced true # defaults already synced
      end
			# AppRouter.replace(PATH, ErotripSearchParser.encode(default_search_params, ENCODER_OPTIONS))
		end
	end

	after_mount do
		if CurrentUserStore.current_user_id.blank?
			AppRouter.push "/users"
		end

		UpdateUserVisits.run(visit: 'peepers').then do |response|
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

	def default_search_params
		{
			visitor_kind_in:           [],
			visitor_looking_for:  [],
			visitor_city_eq:           '',
			visitor_is_verified_eq:    nil,
			visitor_is_drinker_eq:     nil,
			visitor_is_smoker_eq:      nil,
			visitor_within_range:      [0, nil],
			visitor_with_photos:       nil,
			visitor_without_photos:    nil,
			visitor_birth_year_or_visitor_birth_year_second_person_lteq:   Time.now.year - 18,
			visitor_birth_year_or_visitor_birth_year_second_person_gteq:   Time.now.year - 50,
			visitor_height_lteq:       nil,
			visitor_height_gteq:       nil,
			height:                    '',
			visitor_body_in:           [],
			visitor_interests_id_in:   [],
			visitor_online_recently:   nil,
			visitor_online_now:        nil,
			sorts:             VISIT_SORT_OPTIONS[0][:value]
		}
	end

	def render
		peepers_scope = Visit.for_visitee(CurrentUserStore.current_user_id).ransacked(prepare_search_params(state.search_params))

		div(class: 'row') do
			div(class: 'col-12 col-xl-9 ml-xl-auto main-content') do

				UsersSearchBox(
          users_count: state.search_params.present? && state.search_params.keys.try(:size) > 0 && peepers_scope.loaded? ? peepers_scope.count : nil,
          current_user: CurrentUserStore.current_user,
          search_params: default_search_params,
          sort_options: VISIT_SORT_OPTIONS,
					ransack_context: 'visitor_',
					rows_count_one: "użytkownik",
					rows_count_many: "użytkowników",
					ero_path_name: 'Podglądacz',
					sync_search_params: !state.search_params_synced,
					new_search_params: state.search_params,
					on_search_params_sync: proc{ search_params_synced },
        ).on :change do |e|
          search_changed e.to_n
        end

        if state.search_params.present? && state.search_params.keys.size > 0 && peepers_scope.loaded?

					div(class: "row people-wrapper") do
            if peepers_scope.size > 0
  						peepers_scope.limit(state.per_page).offset((state.current_page - 1) * state.per_page).each do |visit|
  							UserSquare(user: visit.visitor, avatar_url: visit.visitor.try(:avatar_url), show_locker: false, can_redirect: !visit.visitor.try(:is_private))
              end

            else
              div(class: "placeholder") do
                i(class: "ero-eye f-s-30 text-primary")
                span() {'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.'}
              end
            end
          end

					Pagination(
						page: state.current_page,
						per_page: state.per_page,
						total: peepers_scope.count
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

	# User changed search
	def search_changed options
    mutate.current_page 1
    mutate.search_params options[:terms]
    history.push(location.pathname, {terms: state.search_params, page: state.current_page}.to_json)
	end

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

	def prepare_search_params params
		new_params = params.dup
		if (new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] && (Time.now.year - new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] >= 50))
			new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] = nil
		end

		if new_params["#{PARSE_SCOPE}city_eq"].present?
			if new_params["#{PARSE_SCOPE}within_range"][0] > 0
        new_params["#{PARSE_SCOPE}city_eq"] = nil
				new_params["#{PARSE_SCOPE}find_in_bounds"] = nil
			else
				new_params["#{PARSE_SCOPE}within_range"] = [0, nil]
			end
		else
			new_params["#{PARSE_SCOPE}find_in_bounds"] = nil
			new_params["#{PARSE_SCOPE}within_range"] = [0, nil]
		end

		new_params
	end
end