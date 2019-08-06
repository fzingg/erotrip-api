class GroupsIndexSearchBox < Hyperloop::Component
  param onChange: nil
	param groups_count: 0
	param search_params: {}
	param sort_options: {}
  param ero_path_name: 'Grupy'

  param sync_search_params: nil
  param new_search_params: nil
  param on_search_params_sync: nil

  state opened: false
  state opened_and_visible: false
	state search_params: {}
	state sort_options:	{}
  state typed_search_timeout: nil

	# before_mount :propagate_change

	# before_unmount do
	# 	MobileSearchButtonStore.hide
	# end

  # before_mount do
  #   mutate.search_params params.search_params
  #   mutate.sort_options params.sort_options
  #   propagate_change
  # end


  before_receive_props do |new_props|
    if new_props[:sync_search_params] && new_props[:new_search_params].present?
      mutate_search_params(new_props[:new_search_params])
      params.on_search_params_sync.call() if params.on_search_params_sync.present?
    end
  end

  before_mount do
    mutate.search_params params.search_params
    mutate.sort_options params.sort_options

    if params.sync_search_params && params.new_search_params.present?
      mutate_search_params(params.new_search_params)
      params.on_search_params_sync.call() if params.on_search_params_sync.present?
    end
  end

  after_mount do
		MobileSearchButtonStore.show
		MobileSearchButtonStore.on_trigger(proc { open_search })
  end

  def mutate_search_params incoming_params
    new_params = state.search_params.dup
    incoming_params.keys.each do |key|
      new_params[key] = incoming_params[key]
    end
    mutate.search_params new_params
  end


  def add_group
    ModalsService.open_modal('GroupsNewModal', { size_class: 'modal-lg' })
	end

	def open_search
		if state.opened
      mutate.opened_and_visible false
      mutate.opened false
      # MobileSearchButtonStore.hide
    else
      mutate.opened true
      # MobileSearchButtonStore.show
      after(1) do
        if state.opened
          mutate.opened_and_visible true
        end
      end
    end
	end

	def propagate_change
		# mutate.search_params params.search_params
		# mutate.sort_options params.sort_options
    # params.onChange.call(state.search_params) if params.onChange.present?
    terms = state.search_params.dup
    # params.onChange.call(terms) if params.onChange.present?
    params.onChange.call({ terms: terms }) if params.onChange.present?
  end

  def render
    form(class: 'search') do

      #mobile header
      div(class: 'search-header-mobile pt-3 pb-3 d-block d-md-none') do
        span(class: 'info') do
          span(class: 'text-regular mr-2') { "#{params.ero_path_name}" }
          span(class: 'text-primary mr-2') { "#{params.groups_count}" }
        end
      end

      # desktop header
      div(class: 'search-header d-none d-md-flex') do
        # Pluralized(class: 'info f-s-16', count: params.groups_count, one: 'grupa', few: 'grupy', many: 'grup')
        span(class: 'info f-s-20') do
          span(class: 'text-regular mr-3') { "#{params.ero_path_name}" }
          span(class: 'text-primary') { "#{params.groups_count}" }
        end

        div(class: 'search-input') do
          SearchBarButton(classNames: 'mr-3', i: 'ero-cross').on(:click) { add_group }

          div(class: 'd-none d-md-block mr-md-3') do
            input(class:'form-control', style: {width: '210px'}, defaultValue: state.search_params['name_or_desc_cont'], placeholder: "Szukaj w nazwie i opisie", name: 'name_or_desc_cont').on :key_up do |e|
              mutate.search_params['name_or_desc_cont'] = e.target.value
              if state.typed_search_timeout
                state.typed_search_timeout.abort
              end
              mutate.typed_search_timeout(after(1) do
                propagate_change
                mutate.typed_search_timeout nil
              end)
            end
          end

          # SearchBarButton(class: ['mr-3', active: state.opened], i: 'ero-search').on(:click) do
          #   if state.opened
          #     mutate.opened_and_visible false
          #     mutate.opened false
          #   else
          #     mutate.opened true
          #     after(1) do
          #       if state.opened
          #         mutate.opened_and_visible true
          #       end
          #     end
          #   end
          # end

          Select(name: 'sorts', clearable: false, backspaceRemoves: false, deleteRemoves: false, placeholder: 'Sortuj', options: state.sort_options, selection: state.search_params['sorts']).on :change do |e|
            mutate.search_params['sorts'] = e.to_n
            propagate_change
          end
        end
      end


      # div(class: 'search-header d-none d-md-flex') do
      #   Pluralized(class: 'info f-s-16', count: params.hotline_count, one: params.rows_count_one, few: params.rows_count_few, many: params.rows_count_many)

      #   div(class: 'search-input') do
      #     SearchBarButton(class: ['mr-3', active: state.opened], i: 'ero-search').on(:click) do
      #       if state.opened
      #         mutate.opened_and_visible false
      #         mutate.opened false
      #       else
      #         mutate.opened true
      #         after(1) do
      #           if state.opened
      #             mutate.opened_and_visible true
      #           end
      #         end
      #       end
      #     end
      #     Select(name: 'sorts', clearable: false, backspaceRemoves: false, deleteRemoves: false, placeholder: 'Sortuj', options: params.sort_options, selection: state.search_params['sorts']
      #     ).on :change do |e|
      #       mutate.search_params['sorts'] = e.to_n
      #       propagate_change
      #     end
      #   end
      # end

      div(class: "search-container#{' open' if state.opened}#{' visible' if state.opened && state.opened_and_visible} d-md-none") do
        div(class: 'search-container-overflow-control') do
          div(class: 'row search-header d-md-none') do
            div(class: 'col-12') do
              span(class: 'text-white f-s-22 text-book') {'Wyszukaj'}
              button(class: 'btn btn-outline-primary btn-outline-gray btn-close icon-only', type: "button") do
                i(class: 'ero-cross rotated-45deg')
              end.on :click do |e|
                e.prevent_default
                mutate.opened_and_visible false
                mutate.opened false
              end
            end
          end

          div(class: "row search-body") do
            div(class: 'col-12 search-preferences') do

              div(class: 'form-group d-md-none') do
                label {'Szukaj w nazwie i opisie'}
                input(class:'form-control', value: state.search_params['name_or_desc_cont'], placeholder: "Szukaj w nazwie i opisie", name: 'name_or_desc_cont').on :change do |e|
                  mutate.search_params['name_or_desc_cont'] = e.target.value
                end
              end

              div(class: 'row d-flex d-md-none') do
                div(class: 'col-12') do
                  div(class: 'form-group') do
                    Select(name: 'sorts', clearable: false, backspaceRemoves: false, deleteRemoves: false, placeholder: 'Sortuj', options: state.sort_options, selection: state.search_params['sorts']
                    ).on :change do |e|
                      mutate.search_params['sorts'] = e.to_n
                      propagate_change
                    end
                  end
                end
              end

            end
          end

          div(class: "row search-footer") do
            div(class: 'col-12 text-center') do
              button(class: 'btn btn-secondary mr-0 mr-md-4', type: "submit") do
                'Pokaż'
              end
              button(class: 'btn btn-outline-primary btn-outline-cancel text-gray text-medium d-none d-md-inline-block', type: "button") do
                'Anuluj'
              end.on :click do |e|
                e.prevent_default
                mutate.opened false
                mutate.opened_and_visible false
              end
            end
          end
        end
      end
    end.on :submit do |e|
      e.prevent_default
      mutate.opened false
      mutate.opened_and_visible false
      propagate_change
    end
  end

  def  mobile_range_text
    if lonlat_present? && state.search_params["#{params.ransack_context}city_eq"] != ''
      if state.search_params["#{params.ransack_context}within_range"][0].floor == 0
        span { state.search_params["#{params.ransack_context}city_eq"] }
      else
        span() { state.search_params["#{params.ransack_context}city_eq"] }
        span() { " + #{state.search_params["#{params.ransack_context}within_range"][0].floor} km" }
      end
    else
      "Cała polska"
    end
  end

end








#     form.search do
#       #mobile header
#       div(class: 'search-header-mobile pt-3 pb-3 d-flex d-md-none') do
#         # SearchBarButton(class: ['mr-3', active: state.opened], i: 'ero-search').on(:click) { open_search }

#         div do
#           p(class: "active-filters d-inline-block m-0 pl-2 pr-2") { (state.sort_options.select { |e| e[:value] == state.search_params[:sorts] })[0][:label] }
#         end

#         SearchBarButton(class: 'ml-3', i: 'ero-cross').on(:click) { add_group }
#       end

#       # desktop header
#       div(class: 'search-header d-none d-md-flex') do
#         Pluralized(class: 'info f-s-16', count: params.groups_count, one: 'grupa', few: 'grupy', many: 'grup')

# 				div(class: 'search-input') do
# 					SearchBarButton(class: 'ml-3 mr-3', i: 'ero-cross').on(:click) { add_group }
#           SearchBarButton(class: ['mr-3', active: state.opened], i: 'ero-search').on(:click) { mutate.opened !state.opened }

#           Select(name: 'sorts', clearable: false, backspaceRemoves: false, deleteRemoves: false, placeholder: 'Sortuj', options: state.sort_options, selection: state.search_params['sorts']).on :change do |e|
#             mutate.search_params['sorts'] = e.to_n
#             propagate_change
#           end
#         end
#       end

#       div(class: "row search-body search-body-small align-content-start #{'open' if state.opened}") do
#         div(class: 'col-12 search-floating-header d-md-none') do
#           span(class: 'text-white f-s-22 text-book') {'Wyszukaj'}
#           button(class: 'btn btn-outline-primary btn-outline-gray btn-close icon-only', type: "button") do
#             i(class: 'ero-cross rotated-45deg')
#           end.on :click do |e|
#             e.prevent_default
#             mutate.opened false
#             mutate.search_params DEFAULT_SEARCH_PARAMS.dup
#             propagate_change
#           end
#         end

#         div(class: 'col-12 search-preferences') do
#           div(class: 'row') do
#             div(class: 'col-12 col-md-6') do
#               div(class: 'form-group') do
#                 label {'Szukam'}
#                 MultiSelect(placeholder: "Szukam", name: 'for_kinds[]', selection: state.search_params['for_kinds'], options: Commons.account_kinds).on :change do |e|
#                   mutate.search_params['for_kinds'] = e.to_n
#                 end
#               end
#             end
#             div(class: 'col-12 col-md-6') do
#               div(class: 'form-group') do
#                 label {'Nazwa'}
#                 input(class: 'form-control', value: state.search_params['name_cont'], placeholder: "Nazwa", name: 'name_cont').on :change do |e|
#                   mutate.search_params['name_cont'] = e.target.value
#                 end
#               end
#             end
#           end
#         end

#         div(class: 'col search-footer') do
#           button(class: 'btn btn-secondary mr-0 mr-md-4', type: "submit") do
#             'Pokaż'
#           end
#           button(class: 'btn btn-outline-primary btn-outline-gray text-gray', type: "button") do
#             'Anuluj'
#           end.on :click do |e|
#             e.prevent_default
#             mutate.opened false
#             mutate.search_params DEFAULT_SEARCH_PARAMS.dup
#             propagate_change
#           end
#         end
#       end
#     end.on :submit do |e|
#       e.prevent_default
#       mutate.opened false
#       propagate_change
#     end
#   end
# end