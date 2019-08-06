class HotlineIndex < Hyperloop::Router::Component
  PATH = 'hotline'

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
      string_or_empty_string: ["#{PARSE_SCOPE}city_eq", "height"],
      array_or_empty_array: ["body_in", "looking_for", "kind_in", "interests_id_in"].map{ |key| "#{PARSE_SCOPE}#{key}" },
      array_or_nil: ["#{PARSE_SCOPE}find_in_bounds"],
      array_values_to_int: ["#{PARSE_SCOPE}interests_id_in"]
    },
    after_decode: (proc do |hash|
      ErotripUsersSearchEncoder.handle_decode(hash, PARSE_SCOPE)
    end)
  }

  state current_page: 1
  state per_page: 25

  state search_params: {}
  state hotline_id_to_remove: nil
  state remove_timeout: nil

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
    # if location.search.present?
    #   puts "> APPLYING SEARCH"

    #   decoded = ErotripSearchParser.decode(location.search, DECODER_OPTIONS)
    #   if decoded["page"] && decoded["page"].to_i > 0
    #     mutate.current_page decoded["page"].to_i
    #   end

    #   proper_params = default_search_params
    #   decoded.keys.each do |key|
    #     proper_params[key] = decoded[key]
    #   end
    #   mutate.search_params proper_params
    #   mutate.search_params_synced false
    #   # mutate.search_params decoded
    #   # mutate.search_params_synced false

    elsif CurrentUserStore.current_user_id.present?
      CurrentUserStore.on_current_user_load(proc do
        if CurrentUserStore.current_user.predefined_hotline.present?
          puts "> APPLYING PREDEFINED"

          new_params = CurrentUserStore.current_user.predefined_hotline
          new_params['sorts'] = default_search_params['sorts']
          mutate.search_params CurrentUserStore.current_user.predefined_hotline
          mutate.search_params_synced false
          # AppRouter.replace(PATH, ErotripSearchParser.encode(new_params, ENCODER_OPTIONS))
        else
          apply_defaults
          mutate.search_params_synced false if always_sync
        end
      end)
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

  def sort_options(current_user=nil)
    result = [
      { value: 'created_at desc', label: 'Najnowsze'  },
      { value: 'mine', label: 'Moje', auth: true}
    ]

    result
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
      content_cont:          '',
      user_kind_in:          [],
      user_looking_for:      [],
      city_eq:               '',
      within_range:          [0, nil],
      user_id_eq:            nil,
      user_is_verified_eq:   nil,
      user_is_drinker_eq:    nil,
      user_is_smoker_eq:     nil,
      user_with_photos:      nil,
      user_without_photos:   nil,
      user_birth_year_or_user_birth_year_second_person_lteq:  Time.now.year - 18,
      user_birth_year_or_user_birth_year_second_person_gteq:  Time.now.year - 50,
      height:           '',
      user_height_lteq:      nil,
      user_height_gteq:      nil,
      user_body_in:          [],
      user_interests_id_in:  [],
      sorts:                 sort_options[0][:value]
    }
  end

  def remove_me id
    mutate.hotline_id_to_remove id

        # if(!event.target.classList.contains('js-propagate')){
        #   event.stopPropagation()
        # }

        # event.preventDefault()
    %x|
      callback = function(event) {
        #{cancel_remove}
        document.body.removeEventListener('click', callback)
      }

      document.body.addEventListener('click', callback)
    |

    if state.remove_timeout
      state.remove_timeout.abort
    end
    mutate.remove_timeout(after(5000) do
      cancel_remove
    end)
  end

  def cancel_remove
    mutate.hotline_id_to_remove nil
    mutate.remove_timeout nil
  end

  def today
    now = Time.now
    Time.new(now.year, now.month, now.day, 0, 0, 0)
  end

  def render

    hotline_scope = Hotline.ransacked(prepare_search_params(state.search_params)).created_after((today - 1.month).to_s)

    div(class: 'row') do
      div(class: 'col-12 col-xl-9 ml-xl-auto main-content') do

        # HotlineCarousel()

        # HotlineSearchBox(
        #   hotlines_count: hotline_scope.count,
        #   search_params: default_search_params,
        #   sort_options: sort_options(CurrentUserStore.current_user_id.present?)
        # ).on :change do |new_params|
        #   search_changed new_params.to_n
        # end


        HotlineSearchBox(
          hotline_count: state.search_params.present? && state.search_params.keys.size > 0 && hotline_scope.loaded? ? hotline_scope.count : nil,
          current_user: CurrentUserStore.current_user,
          search_params: default_search_params,
          sort_options: sort_options(CurrentUserStore.current_user),
          ransack_context: 'user_',
          rows_count_one: "ogłoszenie",
          rows_count_few: "ogłoszenia",
          rows_count_many: "ogłoszeń",
          ero_path_name: 'Hotline',
          sync_search_params: !state.search_params_synced,
          new_search_params: state.search_params,
          on_search_params_sync: proc{ search_params_synced }
        ).on :change do |e|
          search_changed e.to_n
        end

        if state.search_params.present? && state.search_params.keys.size > 0 && hotline_scope.loaded?
          if hotline_scope.size > 0
            hotline_scope.limit(state.per_page).offset((state.current_page - 1) * state.per_page).each do |hotline|
              if hotline.try(:created_at).present?
                HotlineHotline(hotline: hotline, display_buttons: true, about_to_remove: state.hotline_id_to_remove == hotline.try(:id), on_remove_init: proc{ |id| remove_me(id) } )
              end
            end

          elsif hotline_scope.size == 0
            div(class: "placeholder") do
              i(class: "ero-hotline f-s-30 text-primary")
              span() {'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.'}
            end
          end

          Pagination(page: state.current_page, per_page: state.per_page, total: hotline_scope.count).on :change do |e|
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

    # mutate.current_page 1
    # mutate.search_params options[:terms]

    mutate.current_page 1
    mutate.search_params options[:terms]
    puts "state params after mutation: #{state.search_params}"
    history.push(location.pathname, {terms: state.search_params, page: state.current_page}.to_json)
  end

  # User changed page
  def page_changed page
    # terms = state.search_params
    # terms[:page] = page
    # AppRouter.push(PATH, ErotripSearchParser.encode(terms, ENCODER_OPTIONS))
    # mutate.current_page page

    terms = state.search_params
    terms[:page] = page
    mutate.current_page page
    # AppRouter.push(PATH, ErotripSearchParser.encode(terms, ENCODER_OPTIONS))
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

  def search_params_synced
    mutate.search_params_synced true
  end

  def prepare_search_params params
    new_params = params.dup
    if (new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] && (Time.now.year - new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] >= 50))
      new_params["#{PARSE_SCOPE}birth_year_or_#{PARSE_SCOPE}birth_year_second_person_gteq"] = nil
    end

    if new_params["city_eq"].present?
      if new_params["within_range"][0] > 0
        new_params["city_eq"] = nil
        new_params["find_in_bounds"] = nil
      else
        new_params["within_range"] = [0, nil]
      end
    else
      new_params["find_in_bounds"] = nil
      new_params["within_range"] = [0, nil]
    end
    if new_params['sorts'] == 'mine'
      new_params['sorts'] = 'created_at desc'
    end
    puts new_params.inspect
    new_params
  end
end