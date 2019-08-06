class GroupsIndex < Hyperloop::Router::Component

	SORT_OPTIONS = [
		{ value: 'all_users_count desc', label: "Najpopularniejsze"},
    { value: 'created_at desc', label: 'Najnowsze'  }
  ]

  PARSE_SCOPE = nil

  ENCODER_OPTIONS = {
    before_encode: (proc do |data|
      ErotripUsersSearchEncoder.handle_encode(data, PARSE_SCOPE)
    end)
  }

  DECODER_OPTIONS = {
    parse: {
      string_or_empty_string: ["name_cont"],
      numeric_or_nil: [],
      boolean_or_nil: [],
      array_or_empty_array: [],
      array_or_nil: [],
      array_values_to_int: []
    },
    after_decode: (proc do |hash|
      # ErotripUsersSearchEncoder.handle_decode(hash, PARSE_SCOPE)
    end)
  }

  state total: 0
  state current_page: 1
  state per_page: 25

	state search_params: {}
	state group_id_to_remove: nil
	state remove_timeout: nil
  state search_params_synced: true
  state history_listener: nil

  before_mount do
    load_resources
  end


  after_mount do
    mutate.history_listener (history.listen do |location, action|
      on_location_change(location, action)
    end)
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
    #   # if decoded['sorts'].blank?
    #   #   decoded['sorts'] = default_search_params['sorts']
    #   # end
    #   proper_params = default_search_params
    #   decoded.keys.each do |key|
    #     proper_params[key] = decoded[key]
    #   end
    #   mutate.search_params proper_params
    #   mutate.search_params_synced false
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

  # before_unmount do
  #   state.history_listener.call() if state.history_listener.present?
  # end


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

  def default_search_params
    {
      # for_kinds:            [],
      name_cont:            '',
      sorts:                SORT_OPTIONS[0][:value]
    }
	end

	def remove_me id
    mutate.group_id_to_remove id
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
    mutate.group_id_to_remove nil
    mutate.remove_timeout nil
  end

  def search_params_synced_handler
    mutate.search_params_synced true
  end

  def render
    groups_scope = Group.ransacked(state.search_params)

    div(class: 'row') do
      div(class: 'col-12 col-xl-9 ml-xl-auto main-content') do

        # HotlineCarousel()

        GroupsIndexSearchBox(
          groups_count: state.search_params.keys.size > 0 && groups_scope.loaded? ? groups_scope.count : nil,
          sort_options: SORT_OPTIONS,
          ero_path_name: 'Grupy',
          search_params: default_search_params,
          sync_search_params: !state.search_params_synced,
          new_search_params: state.search_params,
          on_search_params_sync: proc{ search_params_synced_handler },
        ).on :change do |e|
          search_changed e.to_n
        end

        if state.search_params.keys.size > 0 && groups_scope.loaded?

          if groups_scope.size > 0
            groups_scope.limit(state.per_page).offset((state.current_page - 1) * state.per_page).each do |group|
							user_group_ransack = nil
							if CurrentUserStore.current_user && CurrentUserStore.current_user_id && CurrentUserStore.current_user.id.loaded? && group.try(:id) && group.id.loaded?
								user_group_ransack = { user_id_eq: CurrentUserStore.current_user.id, group_id_eq: group.try(:id) }
							end
              GroupSingle(
								group: group,
								about_to_remove: state.group_id_to_remove == group.try(:id),
								user_group: if user_group_ransack.present? then UserGroup.ransacked(user_group_ransack).first else nil end,
								on_remove_init: proc{ |id| remove_me(id) }
							)
            end

          elsif groups_scope.size == 0
            div(class: "placeholder") do
              i(class: "ero-groups f-s-30 text-primary")
              span() {'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.'}
            end
          end

          Pagination(page: state.current_page,
            per_page: state.per_page,
            total: groups_scope.count
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

  def group_action_button group
    if group.users.include? CurrentUserStore.current_user
      button(class: "btn icon-only btn-container text-white white-border btn-top secondary-bg active", type: "button") do
        i(class: "f-s-18 ero-cross")
      end.on :click do |e|
        join_group(group)
      end
    else
      button(class: "btn icon-only btn-container text-white white-border btn-top #{false ? 'bg-gray-200' : 'secondary-bg'}", type: "button") do
        i(class: "f-s-18 ero-cross")
      end.on :click do |e|
        join_group(group)
      end
    end
  end

  def join_group(group)
    ModalsService.open_modal('GroupsJoinModal', { group: group })
  end

  def search_changed options
    # AppRouter.push(PATH, ErotripSearchParser.encode(options[:terms], ENCODER_OPTIONS))

    # mutate.current_page 1
    # mutate.search_params options[:terms]

    # # if terms['sorts'] != state.search_params['sorts'] && state.current_page != 1
    #   mutate.current_page 1
    # # end
    # mutate.search_params terms

    mutate.current_page 1
    mutate.search_params options[:terms]
    history.push(location.pathname, {terms: state.search_params, page: state.current_page}.to_json)
  end

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
end