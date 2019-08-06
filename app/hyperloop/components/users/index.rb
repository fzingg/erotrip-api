class UsersIndex < Hyperloop::Router::Component

  USER_SORT_OPTIONS = [
    { value: 'created_at desc',             label: 'Najnowsze' },
    { value: 'online_now',                  label: 'Teraz online' },      # ransacker
    { value: 'online_recently',             label: 'Ostatnio byli' },     # ransacker
  ]

  PATH = 'users'

  PARSE_SCOPE = ''

  ENCODER_OPTIONS = {
    before_encode: (proc do |data|
      ErotripUsersSearchEncoder.handle_encode(data, PARSE_SCOPE)
    end)
  }

  DECODER_OPTIONS = {
    parse: {
      numeric_or_nil: ["page", "birth_year_or_birth_year_second_person_gteq", "birth_year_or_birth_year_second_person_lteq", "height_gteq", "height_lteq"],
      boolean_or_nil: ["active_recently", "is_smoker_eq", "is_drinker_eq", "is_verified_eq", "online_now", "online_recently", "with_photos", "without_photos"],
      string_or_empty_string: ["city_eq", "height"],
      array_or_empty_array: ["body_in", "looking_for", "kind_in", "interests_id_in"],
      array_or_nil: ["find_in_bounds"],
      array_values_to_int: ["interests_id_in"]
    },
    after_decode: (proc do |hash|
      ErotripUsersSearchEncoder.handle_decode(hash, PARSE_SCOPE)
    end)
  }

  state :users

  state current_page: 1
  state per_page: 24

  state search_params: {}

  state history_listener: nil
  state search_params_synced: true
  state wait_for_load: true

  before_mount do
    load_resources
  end

  def load_resources always_sync=false
    if location.state.present? && location.state.index('terms').present?
      locationState = JSON.parse(location.state)
      mutate.search_params locationState['terms']
      mutate.current_page locationState['page'].to_i > 0 ? locationState['page'].to_i : 1
      mutate.search_params_synced false
    # if location.search.present?
    #   decoded = ErotripSearchParser.decode(location.search, DECODER_OPTIONS)
    #   if decoded["page"] && decoded["page"].to_i > 0
    #     mutate.current_page decoded["page"].to_i
    #   end
    #   # if decoded['sorts'].blank?
    #   #   decoded['sorts'] = default_search_params['sorts']
    #   # end
    #   proper_params = default_search_params
    #   decoded.keys.each do |key|
    #     proper_params[key] = decoded[key]
    #   end
    #   mutate.search_params proper_params
    #   mutate.search_params_synced false
    #   mutate.wait_for_load false

    elsif CurrentUserStore.current_user_id.present?
      # User.find(CurrentUserStore.current_user_id).load(:predefined_users).then do |predefined_users|
      CurrentUserStore.on_current_user_load(proc do
        if CurrentUserStore.current_user.predefined_users.present?
          new_params = CurrentUserStore.current_user.predefined_users
          new_params["kind_in"] = CurrentUserStore.current_user.predefined_users["only_users_search_kind_in"]
          new_params['sorts'] = default_search_params['sorts']
          mutate.search_params new_params
          mutate.search_params_synced false
          # AppRouter.replace(PATH, ErotripSearchParser.encode(new_params, ENCODER_OPTIONS))
          mutate.wait_for_load false
        else
          apply_defaults
          mutate.search_params_synced false if always_sync
          mutate.wait_for_load false
        end
      end)
   #    CurrentUserStore.on_current_user_load(proc do
      # end)
    else
      apply_defaults
      mutate.search_params_synced false if always_sync
      mutate.wait_for_load false
    end
  end

  def apply_defaults
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
      kind_in:              [],
      looking_for:          [],
      strictly_looking_for: [],
      city_eq:           '',
      is_verified_eq:    nil,
      is_drinker_eq:     nil,
      is_smoker_eq:      nil,
      within_range:      [0, nil],
      find_in_bounds:    nil,
      with_photos:       nil,
      without_photos:    nil,
      birth_year_or_birth_year_second_person_lteq:   Time.now.year - 18,
      birth_year_or_birth_year_second_person_gteq:   Time.now.year - 50,
      online_recently:   nil,
      height_lteq:       nil,
      height_gteq:       nil,
      online_now:        nil,
      active_recently:   nil,
      body_in:           [],
      interests_id_in:   [],
      sorts:             USER_SORT_OPTIONS[0][:value],
      # id_not_eq:         CurrentUserStore.current_user_id
    }
  end

  def render
    users_scope = User.where_id_not(CurrentUserStore.current_user_id).ransacked(prepare_search_params(state.search_params))

    div(class: 'row') do
      div(class: 'col-12 col-xl-9 ml-xl-auto main-content') do
        UsersSearchBox(
          users_count: (state.search_params.present? && state.search_params.keys.try(:size) > 0) && users_scope.loaded? ? users_scope.count : nil,
          current_user: CurrentUserStore.current_user,
          search_params: default_search_params,
          sort_options: USER_SORT_OPTIONS,
          ransack_context: '',
          ero_path_name: 'Osoby',
          sync_search_params: !state.search_params_synced,
          new_search_params: state.search_params,
          on_search_params_sync: proc{ search_params_synced_handler },
          do_save_filters: true,
          do_sync_searched_kinds: true,
        ).on :change do |e|
          search_changed(e.to_n)
        end

        # div { "state.search_params.present? #{state.search_params.present?}" }
        # div { "state.search_params.keys.try(:size) > 0 #{state.search_params.keys.try(:size) > 0 }" }
        # div { "users_scope.loaded? #{users_scope.loaded?}" }
        if state.search_params.present? && state.search_params.keys.try(:size) > 0 && users_scope.loaded?
          # BlockUi(tag: "div", blocking: users_scope.loading?, class: "row people-wrapper") do

          div(class: "row people-wrapper") do
            if users_scope.count > 0
              users_scope.limit(state.per_page).offset((state.current_page - 1) * state.per_page).each do |user|
                # UserSquare(user: user, avatar_url: user.try(:avatar_url), show_locker: false, can_redirect: !user.try(:is_private))
                UserSquare(user: user, show_locker: false)
              end

            else
              div(class: "placeholder") do
                i(class: "ero-users f-s-30 text-primary")
                span() {'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.'}
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
    # AppRouter.push(PATH, ErotripSearchParser.encode(options[:terms], ENCODER_OPTIONS))

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
    if action == 'POP'
      load_resources(true)
    end
    # if action == "POP" && location.search.present?
    #   mutate.search_params_synced false
    #   decoded = ErotripSearchParser.decode(location.search, DECODER_OPTIONS)
    #   if decoded["page"]
    #     mutate.current_page decoded["page"]
    #   end
    #   mutate.search_params decoded
    # end
  end

  def search_params_synced_handler
    mutate.search_params_synced true
  end

  def prepare_search_params params
    new_params = params.dup
    if new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] && (Time.now.year - new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] >= 50)
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