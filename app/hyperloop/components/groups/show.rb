class GroupsShow < Hyperloop::Router::Component

  SORT_OPTIONS = [
    { value: 'user_created_at desc',     label: 'Najnowsze'    },
		{ value: 'online_now',               label: 'Teraz online' },  # ransacker
		{ value: 'online_recently',          label: 'Ostatnio byli' }, # ransacker
	]

	PARSE_SCOPE = "user_"

	ENCODER_OPTIONS = {
		before_encode: (proc do |data|
			ErotripUsersSearchEncoder.handle_encode(data, PARSE_SCOPE)
		end)
	}

	DECODER_OPTIONS = {
		parse: {
			numeric_or_nil: ["page", "#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq", "#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_lteq", "#{PARSE_SCOPE}height_gteq", "#{PARSE_SCOPE}height_lteq"],
			boolean_or_nil: ["active_recently", "is_smoker_eq", "is_drinker_eq", "is_verified_eq", "online_now", "online_recently", "with_photos", "without_photos"].map{ |key| "#{PARSE_SCOPE}#{key}" },
			string_or_empty_string: ["city_eq", "height"],
			array_or_empty_array: ["body_in", "looking_for", "kind_in", "interests_id_in"].map{ |key| "#{PARSE_SCOPE}#{key}" },
			array_or_nil: ["#{PARSE_SCOPE}find_in_bounds"],
			array_values_to_int: ["#{PARSE_SCOPE}interests_id_in"]
		},
		after_decode: (proc do |hash|
			ErotripUsersSearchEncoder.handle_decode(hash, PARSE_SCOPE)
		end)
	}

  def default_search_params
    {
      user_kind_in:           [],
      user_looking_for:       [],
      user_city_eq:           '',
      user_is_verified_eq:    nil,
      user_is_drinker_eq:     nil,
      user_is_smoker_eq:      nil,
      user_within_range:      [0, nil],
      user_birth_year_or_user_birth_year_second_person_lteq:   Time.now.year - 18,
			user_birth_year_or_user_birth_year_second_person_gteq:   Time.now.year - 50,
			user_online_now:        nil,
			user_online_recently:   nil,
			height:                 '',
      user_height_lteq:       nil,
      user_height_gteq:       nil,
      user_body_in:           [],
      user_interests_id_in:   [],
      sorts:                  SORT_OPTIONS[0][:value]
    }
  end

  state :group

  state current_page: 1
  state per_page: 20

	state search_params: {}
	state last_visit_time: nil

	state history_listener: nil
	state search_params_synced: true

	def create_path
		"groups/#{match.params.id}"
	end

  before_mount do
		mutate.group Group.find(match.params.id)

		# if location.search.present?
		# 	puts "> APPLYING SEARCH"

		# 	decoded = ErotripSearchParser.decode(location.search, DECODER_OPTIONS)
		# 	if decoded["page"]
		# 		mutate.current_page decoded["page"]
		# 	end
		# 	mutate.search_params decoded
		# 	mutate.search_params_synced false
    if location.state.present? && location.state.index('terms').present?
      locationState = JSON.parse(location.state)
      puts "LOCATION CHANGED!", locationState['terms'].inspect
      mutate.search_params locationState['terms']
      mutate.current_page locationState['page'].to_i > 0 ? locationState['page'].to_i : 1
      mutate.search_params_synced false
		else
			puts "> APPLYING DEFAULTS"

			mutate.search_params default_search_params
			mutate.search_params_synced true # defaults already synced
			# AppRouter.replace(create_path, ErotripSearchParser.encode(default_search_params, ENCODER_OPTIONS))
		end
	end

	after_mount do
		GetUserGroupForActingUser.run(group_id: match.params.id).then do |response|
			if response
				mutate.last_visit_time response
			end
		end
		.fail do |e|
			mutate.last_visit_time nil
		end

		mutate.history_listener (history.listen do |location, action|
			on_location_change(location, action)
		end)
	end

	# before_unmount do
	# 	state.history_listener.call() if state.history_listener.present?
	# end

	def render
    users_scope = UserGroup.for_group(state.group.try(:id).to_i).ransacked(prepare_search_params(state.search_params))

    div(class: 'row') do
      div(class: 'col-12 col-xl-9 ml-xl-auto main-content group-show-content') do

        div(class: 'group-show-wrapper streach-me') do
          div(class: 'patch')
          GroupSingle(group: state.group, user_group: UserGroup.ransacked(user_id_eq: CurrentUserStore.current_user_id, group_id_eq: state.group.try(:id)).first, redirect_after_destroy: true, blue_bordered_button: true)
        end

        UsersSearchBox(
          users_count: users_scope.count,
          current_user: CurrentUserStore.current_user,
          search_params: default_search_params.dup,
          sort_options: SORT_OPTIONS,
					ransack_context: 'user_',
					sync_search_params: !state.search_params_synced,
					new_search_params: state.search_params,
					on_search_params_sync: proc{ search_params_synced }
        ).on :change do |e|
          search_changed e.to_n
        end

        if state.search_params.keys.size > 0 && users_scope.loaded?
          BlockUi(tag: "div", blocking: users_scope.loading?, class: "row people-wrapper") do
            users_scope.each do |user_group|
              if user_group.present? && state.last_visit_time.present? && (Time.parse(state.last_visit_time.to_s).try(:to_i) || 0).try(:<, (user_group.try(:created_at).try(:to_i) || 0)) && user_group.try(:user_id) != CurrentUserStore.current_user_id
                UserSquare(user: user_group.user, avatar_url: user_group.try(:avatar_url), show_locker: user_group.present? ? !user_group.try(:is_public_for, CurrentUserStore.current_user_id) : false, can_redirect: user_group.present? ? user_group.try(:is_public_for, CurrentUserStore.current_user_id) : false, show_indicator: true)
              elsif user_group.present?
                UserSquare(user: user_group.user, avatar_url: user_group.try(:avatar_url), show_locker: user_group.present? ? !user_group.try(:is_public_for, CurrentUserStore.current_user_id) : false, can_redirect: user_group.present? ? user_group.try(:is_public_for, CurrentUserStore.current_user_id) : false, show_indicator: false)
              end
            end
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

        Pagination(
          page: state.current_page,
          per_page: state.per_page,
          total: users_scope.count
        ).on :change do |e|
          page_changed e.to_n
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
      # load_resources(true)
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