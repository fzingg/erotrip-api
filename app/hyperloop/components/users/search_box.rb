class UsersSearchBox < Hyperloop::Component
  state search_params: {}
  state sort_options:  {}
	state opened: false
  state opened_and_visible: false
	state bounds: nil
  state more_options: false
  state no_smoking_checked: false
  state smoking_checked: false
  state no_drinking_checked: false
	state drinking_checked: false
	state interest_options: []
  state in_strict_mode: false

	# state select_options: {}

	MAX_AGE = 50

  param onChange: nil
  param users_count: 0
  param current_user: {}
  param search_params: {}
  param sort_options:  {}
	param ransack_context: ''
  param ero_path_name: 'Osoby'

	param rows_count_one: 'osoba'
	param rows_count_many: 'osób'
  param do_preload: false
	param do_save_filters: false
	param do_sync_searched_kinds: false

	param sync_search_params: nil
	param new_search_params: nil
	param on_search_params_sync: nil

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

		interests = []
		Hyperloop::Model.load do
			interests = Interest.all
			interests.each { |interest| temp = "#{interest.id}#{interest.title.to_s}" }
		end.then do |data|
			mutate.interest_options interests.select{|i| i.id.to_i > 0}.map { |i| { value: i.id.to_i, label: i.title.to_s } }
		end
	end

	after_mount do
		MobileSearchButtonStore.on_trigger(proc { open_search })
		MobileSearchButtonStore.show
	end

	def mutate_search_params incoming_params
		new_params = state.search_params.dup
		incoming_params.keys.each do |key|
			new_params[key] = incoming_params[key]
		end
		if incoming_params["#{params.ransack_context}find_in_bounds"]
			mutate.bounds incoming_params["#{params.ransack_context}find_in_bounds"]
		end
		mutate.search_params new_params
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

	def render
		# INPUT_SER
    form(class: 'search', ref: "#{state.search_form_ref}") do

      #mobile header
      div(class: 'search-header-mobile pt-3 pb-3 d-block d-md-none') do
        span(class: 'info') do
          span(class: 'text-regular mr-2') { "#{params.ero_path_name}" }
          span(class: 'text-primary mr-2') { "#{params.users_count}" }
        end

        p(class: "active-filters mb-0 d-inline-block") { mobile_range_text }
      end

      # desktop header
      div(class: 'search-header d-none d-md-flex') do
        # Pluralized(class: 'info f-s-16', count: params.users_count, one: params.rows_count_one, many: params.rows_count_many)
        span(class: 'info f-s-20') do
          span(class: 'text-regular mr-3') { "#{params.ero_path_name}" }
          span(class: 'text-primary') { "#{params.users_count}" }
        end

        div(class: 'search-input') do
          SearchBarButton(classNames: "mr-3 #{'active' if state.opened }", i: 'ero-search').on(:click) do
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
          Select(name: 'sorts', clearable: false, backspaceRemoves: false, deleteRemoves: false, placeholder: 'Sortuj', options: params.sort_options, selection: state.search_params['sorts']
          ).on :change do |e|
            mutate.search_params['sorts'] = e.to_n
            propagate_change
          end
        end
      end

      div(class: "search-container#{' open' if state.opened}#{' visible' if state.opened && state.opened_and_visible}") do
        div(class: 'search-container-overflow-control') do
          div(class: 'row search-header d-md-none') do
            div(class: 'col-12') do
              span(class: 'text-white f-s-22 text-book') {'Wyszukaj'}
              button(class: 'btn btn-outline-primary btn-outline-gray btn-close icon-only', type: "button") do
                i(class: 'ero-cross rotated-45deg')
              end.on :click do |e|
                e.prevent_default
                # mutate.search_params params.search_params
                # propagate_change
                mutate.opened_and_visible false
                mutate.opened false
                # MobileSearchButtonStore.hide
              end
            end
          end

          div(class: "row search-body") do

            div(class: 'col-12 col-xl-6 search-preferences') do
              div(class: 'row d-flex d-md-none') do
                div(class: 'col-12') do
									div(class: 'form-group') do
                    Select(name: 'sorts', clearable: false, backspaceRemoves: false, deleteRemoves: false, placeholder: 'Sortuj', options: params.sort_options, selection: state.search_params['sorts']
                    ).on :change do |e|
                      mutate.search_params['sorts'] = e.to_n
                      propagate_change
                    end
                  end
                end
              end

              div(class: 'row') do
                div(class: 'col-12 col-md-6') do
                  div(class: 'form-group') do
										label {'Szukam'}
                    MultiSelectWithCheckboxes(
                      placeholder: "Szukam",
                      selection: state.search_params["#{params.ransack_context}kind_in"],
                      options: Commons.account_kinds_declined
                    ).on :change do |e|
                      mutate.search_params["#{params.ransack_context}kind_in"] = e.to_n
										end
                    # BootstrapMultiSelect(
                    #   onChange: proc{ |e, checked| multiselect_changed(e, checked, "kind_in") },
                    #   data: state.select_options['kind_in'].to_n,
                    #   allSelectedText: false,
                    #   multiple: true,
                    #   nonSelectedText: '<span class="no-selection">Szukam</span>',
                    #   enableHTML: true,
                    #   allSelectedText: false,
                    #   numberDisplayed: 100
                    # )
                  end
                end
                div(class: 'col-12 col-md-6') do
                  div(class: 'form-group') do
										label {"Szukających"}
                    MultiSelectWithCheckboxes(
                      placeholder: "Szukających",
                      selection: state.search_params["#{params.ransack_context}looking_for"],
                      options: Commons.account_kinds_declined,
                      show_strict_checkbox: true,
                      onStrictCheckedFromMultiselect: proc { |val| use_strictly_looking_for_in_search_parameters(val) }
                    ).on :change do |e|
                      mutate.search_params["#{params.ransack_context}looking_for"] = e.to_n
                      # puts "MultiSelectWithCheckboxes search_params #{state.search_params}"
                    end

                    # BootstrapMultiSelect(
                    #   onChange: proc{ |e, checked| multiselect_changed(e, checked, "looking_for") },
                    #   data: state.select_options['looking_for'].to_n,
                    #   allSelectedText: false,
                    #   multiple: true,
                    #   nonSelectedText: '<span class="no-selection">Szukających</span>',
                    #   enableHTML: true,
                    #   allSelectedText: false,
                    #   numberDisplayed: 100
                    # )
                  end
                end
              end
            end

    				div(class: 'col-12 col-xl-6 location') do
    					# div(class: "form-group #{'d-none' if city_empty()}") do
    					# 	FormGroup(label: "Gdzie") do
    					# 		Select(
    					# 			placeholder: "Gdzie",
    					# 			clearable: false,
    					# 			backspaceRemoves: false,
    					# 			deleteRemoves: false,
    					# 			options: Commons::MAIN_CITIES,
    					# 			selection: state.search_params["#{params.ransack_context}city_eq"],
    					# 			className: "form-control",
    					# 			onKeyUp: proc { |e| mutate.search_params["#{params.ransack_context}city_eq"] = e }
    					# 		).on :change do |e|
    					# 			city_selected(e.to_n)
    					# 			city_name = e.to_n || ""
    					# 			mutate.search_params["#{params.ransack_context}city_eq"] = city_name.gsub(', Polska', '')
    					# 		end
    					# 	end
    					# end

    					div(class: "form-group") do
								FormGroup(label: "Gdzie") do
    							GooglePlacesAutocomplete(
    								inputProps: { value: state.search_params["#{params.ransack_context}city_eq"], onChange: proc{ |e| city_changed(e)} , placeholder: 'Cała Polska'}.to_n,
    								options: Commons::MAP_OPTIONS.to_n,
    								googleLogo: false,
    								defaultSuggestions: [
    									{ suggestion: "Warszawa", placeId: 0, active: false, index: 0, formattedSuggestion: nil },
    									{ suggestion: "Kraków", placeId: 1, active: false, index: 1, formattedSuggestion: nil },
    									{ suggestion: "Łódź", placeId: 2, active: false, index: 2, formattedSuggestion: nil },
    									{ suggestion: "Wrocław", placeId: 3, active: false, index: 3, formattedSuggestion: nil },
    									{ suggestion: "Poznań", placeId: 4, active: false, index: 4, formattedSuggestion: nil }
    								].to_n,
    								classNames: Commons::CSS_CLASSES.to_n,
										onSelect: proc{ |e| city_selected(e)},
										debounce: 400
    							)
    						end
    					end
    				end

    				# suggestion: p.description,
            # placeId: p.place_id,
            # active: (highlightFirstSuggestion && idx === 0 ? true : false),
            # index: idx,
            # formattedSuggestion: formattedSuggestion(p.structured_formatting),

            div(class: 'col-12 col-xl-6 age') do
							FormGroup(label: 'Wiek') do
								SliderRangeSearchWrapper(
									name: 'age[]',
									selection: user_age_as_array,
									min:  18,
									max: MAX_AGE,
								).on :change do |e|
								  mutate.search_params["#{params.ransack_context}birth_year_or_#{params.ransack_context}birth_year_second_person_lteq"] = Time.now.year - e.to_n[0]
    							mutate.search_params["#{params.ransack_context}birth_year_or_#{params.ransack_context}birth_year_second_person_gteq"] = Time.now.year - e.to_n[1]
								end
              end
    				end

						div(class: 'col-12 col-xl-6 location-range') do
							SliderSearchWrapper(
								name: 'distance',
								selection: state.search_params["#{params.ransack_context}within_range"][0],
								max: 150,
								min: 0,
								step: 150,
								marks: `{10: '', 25: '', 50: '', 75: '', 100: '', 125: '', 150: ''}`,
								city_eq: state.search_params["#{params.ransack_context}city_eq"],
								disabled: !lonlat_present?
							).on :change do |e|
								mutate.search_params["#{params.ransack_context}within_range"][0] = e.to_n
							end
    				end

    				# div(class: 'col-12 col-xl-6 location-range') { '' }

            div(class: 'col-12 col-xl-6 user-height-body-type') do
              div(class: 'row') do
                div(class: 'col-12 col-md-6') do
                  div(class: 'form-group') do
										label {'Wzrost'}
                    SelectWithCheckboxes(
                      placeholder: "Wzrost",
    									selection: state.search_params['height'].to_s,
                      options: Commons::HEIGHT_MAPPING.keys.map { |k| { label: k, value: k }}
    								).on :change do |e|
                      mutate.search_params['height'] = e.to_n

    									if Commons::HEIGHT_MAPPING[e.to_n]
                     	 	mutate.search_params["#{params.ransack_context}height_gteq"] = Commons::HEIGHT_MAPPING[e.to_n]['min']
    										mutate.search_params["#{params.ransack_context}height_lteq"] = Commons::HEIGHT_MAPPING[e.to_n]['max']
    									else
    										mutate.search_params["#{params.ransack_context}height_gteq"] = nil
    										mutate.search_params["#{params.ransack_context}height_lteq"] = nil
    									end
                    end

                    # BootstrapMultiSelect(
                    #   onChange: proc{ |e, checked| height_changed(e, checked, "height") },
                    #   data: state.select_options['height'].to_n,
                    #   allSelectedText: false,
                    #   multiple: true,
                    #   nonSelectedText: '<span class="no-selection">Wzrost</span>',
                    #   ref: "heightMultiRef",
                    #   enableHTML: true,
                    #   allSelectedText: false,
                    #   numberDisplayed: 100
                    # )

                  end
                end

                div(class: 'col-12 col-md-6') do
                  div(class: 'form-group') do
										label {'Sylwetka'}
                    MultiSelectWithCheckboxes(
                      placeholder: "Sylwetka",
                      selection: state.search_params["#{params.ransack_context}body_in"],
                      options: Commons::BODY_TYPES.map {|e| { value: e, label: e} })
                    .on :change do |e|
                      mutate.search_params["#{params.ransack_context}body_in"] = e.to_n
                    end


                    # BootstrapMultiSelect(
                    #   onChange: proc{ |e, checked| multiselect_changed(e, checked, "body_in") },
                    #   data: state.select_options['body_in'].to_n,
                    #   allSelectedText: false,
                    #   multiple: true,
                    #   nonSelectedText: '<span class="no-selection">Sylwetka</span>',
                    #   enableHTML: true,
                    #   allSelectedText: false,
                    #   numberDisplayed: 100
                    # )

                  end
                end
              end
            end

            div(class: 'col-12 col-xl-6 intrests') do

							div(class: 'form-group') do
								label {'W celu'}
								interest_ids = state.search_params["#{params.ransack_context}interests_id_in"] || []
								MultiSelectWithCheckboxes(
									placeholder: "W celu",
									selection: interest_ids.dup,
									options: state.interest_options || []
								).on :change do |e|
									mutate.search_params["#{params.ransack_context}interests_id_in"] = e.to_n
								end
							end

              div(class: 'd-none d-md-flex flex-column ml-3') do
                label(class: 'text-center') {'Więcej'}
                a(class: "btn btn-outline-primary btn-outline-gray icon-only btn-more-options #{ 'active' if state.more_options }") do
                  div(class: 'arrow-down')
                end.on :click do |e|
                  e.prevent_default
                  mutate.more_options !state.more_options
                end
              end
            end

            div(class: "col-12 col-xl-8 m-xl-auto options #{'open' if state.more_options}") do
              div(class: 'row') do

                div(class: 'col-12 col-md-4') do
                  fieldset(class: 'form-group') do
                    legend {'Alkohol'}
                    div(class: 'form-check form-check-inline') do
											label(class: 'form-check-label big-round-label') do
                        input(class: 'form-check-input', type: "checkbox", checked: state.search_params["#{params.ransack_context}is_drinker_eq"] == true).on :change do |e|
                          # mutate.drinking_checked e.target.checked
                          mutate.search_params["#{params.ransack_context}is_drinker_eq"] =  e.target.checked ? true : nil
                          # if e.target.checked
                          #   mutate.no_drinking_checked false
                          # end
                        end
                        span
                        div(class: 'd-flex align-items-center ml-2') {'Pije'}
                      end
                    end
                    div(class: 'form-check form-check-inline') do
											label(class: 'form-check-label big-round-label') do
                        input(class: 'form-check-input', type: "checkbox", checked: state.search_params["#{params.ransack_context}is_drinker_eq"] == false).on :change do |e|
                          # mutate.no_drinking_checked e.target.checked
                          mutate.search_params["#{params.ransack_context}is_drinker_eq"] = e.target.checked ? false : nil
                          # if e.target.checked
                          #   mutate.drinking_checked false
                          # end
                        end
                        span
                        div(class: 'd-flex align-items-center ml-2') {'Nie pije'}
                      end
                    end
                  end
                end

                div(class: 'col-12 col-md-4') do
                  fieldset(class: 'form-group') do
                    legend {'Papierosy'}
                    div(class: 'form-check form-check-inline') do
											label(class: 'form-check-label big-round-label') do
                        input(class: 'form-check-input', type: "checkbox", checked: state.search_params["#{params.ransack_context}is_smoker_eq"] == true).on :change do |e|
                          # mutate.smoking_checked e.target.checked
                          mutate.search_params["#{params.ransack_context}is_smoker_eq"] = e.target.checked ? true : nil
                          # if e.target.checked
                          #   mutate.no_smoking_checked false
                          # end
                        end
                        span
                        div(class: 'd-flex align-items-center ml-2') {"Pali"}
                      end
                    end
                    div(class: 'form-check form-check-inline') do
                      label(class: 'form-check-label big-round-label') do
                        input(class: 'form-check-input', type: "checkbox", checked: state.search_params["#{params.ransack_context}is_smoker_eq"] == false).on :change do |e|
                          # mutate.no_smoking_checked e.target.checked
                          mutate.search_params["#{params.ransack_context}is_smoker_eq"] = e.target.checked ? false : nil
                          # if e.target.checked
                          #   mutate.smoking_checked false
                          # end
                        end
                        span
                        div(class: 'd-flex align-items-center ml-2') {"Nie pali"}
                      end
                    end
                  end
                end

                div(class: 'col-12 col-md-4') do
                  fieldset(class: 'form-group') do
										legend {'Tylko'}
                    div(class: 'form-check form-check-inline') do
                      label(class: 'form-check-label big-round-label') do
                        input(class: 'form-check-input', type: "checkbox", checked: !!state.search_params["#{params.ransack_context}is_verified_eq"]).on :change do |e|
                          mutate.search_params["#{params.ransack_context}is_verified_eq"] = e.target.checked ? true : nil
                        end
                        span
                        div(class: 'd-flex align-items-center ml-2') {'Zweryfikowani'}
                      end
                    end
                    div(class: 'form-check form-check-inline') do
                      label(class: 'form-check-label big-round-label') do
                        input(class: 'form-check-input', type: "checkbox", checked: !!state.search_params["#{params.ransack_context}with_photos"]).on :change do |e|
                          mutate.search_params["#{params.ransack_context}with_photos"] = e.target.checked ? true : nil
                        end
                        span
                        div(class: 'd-flex align-items-center ml-2') {'Ze zdjęciami'}
                      end
                    end
                  end
                end

              end
            end

          end
          div(class: "row search-footer") do
            div(class: 'col-12 text-center') do
              button(class: 'btn btn-secondary mr-0 mr-md-4 text-medium', type: "submit") do
                'Pokaż'
              end
              button(class: 'btn btn-outline-primary btn-outline-cancel text-gray text-medium d-none d-md-inline-block', type: "button") do
                'Anuluj'
              end.on :click do |e|
                e.prevent_default
                mutate.opened false
                mutate.opened_and_visible false
                # MobileSearchButtonStore.hide
                # mutate.search_params params.search_params
                # propagate_change
              end
            end
          end
        end
			end

			div(class: "interest-container select-with-labels search-box-interests d-none d-md-block") do
				selected_interests = state.interest_options.select{ |interest| state.search_params["#{params.ransack_context}interests_id_in"] && state.search_params["#{params.ransack_context}interests_id_in"].include?(interest['value']) }
				div(class: "labels-wrapper #{ 'not-empty' if (selected_interests.size > 0)}") do
					(selected_interests || []).each_with_index do |item, index|
						div(key: index, class: "badge badge-default") do
							input(type: 'hidden', name: params[:name], value: item)
							span do
								item["label"]
							end
							button(type: "button", class: "btn btn-link ml-1") do
								i(class: "ero-cross rotated-45deg f-s-13 d-flex")
							end.on :click do |e|
								remove_interest(index)
							end
						end
					end
				end
			end
		end.on :submit do |e|
      e.prevent_default
      mutate.opened false
			mutate.opened_and_visible false
      propagate_change(true, true)
    end
  end

	def propagate_change(with_save=true, push_history=false, replace_history=false)
		terms = state.search_params.dup

		if state.bounds
			terms["#{params.ransack_context}find_in_bounds"] = state.bounds
		end

		terms["#{params.ransack_context}online_recently"] = nil
		terms["#{params.ransack_context}online_now"] = nil
		terms["#{params.ransack_context}active_recently"] = nil

		if ["online_now", "online_recently"].include?(terms["sorts"])
			terms["#{params.ransack_context}#{terms['sorts']}"] = true
		end

    if params.do_save_filters && params.do_save_filters == true && with_save && CurrentUserStore.current_user.present?
      terms_to_save = state.search_params.dup
			terms_to_save.delete('sorts')

			if terms_to_save["#{params.ransack_context}within_range"].present?
				`
				within_range_lonlat = #{terms_to_save["#{params.ransack_context}within_range"][1]}
				if (within_range_lonlat == null) {
					#{terms_to_save["#{params.ransack_context}within_range"][1] = nil}
				}
				`
			end

			# ZAPISZ TUTAJ DODATKOWO: .predefined_users["only_users_search_kind_in"]
			UpdatePredefined.run({field_name: 'predefined_users', current_terms: terms_to_save})

			if params.do_sync_searched_kinds && CurrentUserStore.current_user.searched_kinds.loaded? && did_searched_kinds_change
				UpdateSearchedKinds.run({searched_kinds: state.search_params["#{params.ransack_context}kind_in"]})
			end
		end

    if state.in_strict_mode
      terms["#{params.ransack_context}strictly_looking_for"] = terms["#{params.ransack_context}looking_for"].dup
      terms["#{params.ransack_context}looking_for"] = []
    end

		params.onChange.call({ terms: terms }) if params.onChange.present?
	end

  def use_strictly_looking_for_in_search_parameters val
    mutate.in_strict_mode val
  end

	def did_searched_kinds_change
		(state.search_params["#{params.ransack_context}kind_in"].try(:size) != CurrentUserStore.current_user.searched_kinds.try(:size)) ||
		((state.search_params["#{params.ransack_context}kind_in"] | CurrentUserStore.current_user.searched_kinds).try(:size) != CurrentUserStore.current_user.searched_kinds.try(:size))
	end

	def remove_interest index
		state.search_params["#{params.ransack_context}interests_id_in"].delete_at(index)
		new_selection = state.search_params["#{params.ransack_context}interests_id_in"] || []
		mutate.search_params["#{params.ransack_context}interests_id_in"] = new_selection.dup
		propagate_change
	end

  def user_age_as_array
    [
      Time.now.year - state.search_params["#{params.ransack_context}birth_year_or_#{params.ransack_context}birth_year_second_person_lteq"],
      Time.now.year - state.search_params["#{params.ransack_context}birth_year_or_#{params.ransack_context}birth_year_second_person_gteq"]
		]
	end

	def city_empty
		mutate.search_params["#{params.ransack_context}city_eq"] == ""
	end

  def mobile_range_text
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

	def range_text
		if lonlat_present? && state.search_params["#{params.ransack_context}city_eq"] != ''
			if lonlat_present?
				if state.search_params["#{params.ransack_context}within_range"][0].floor == 0
					"Całe miasto"
				else
					"W obrębie #{state.search_params["#{params.ransack_context}within_range"][0].floor} km"
				end
			else
				"Cała polska"
			end
		else
			" "
		end
	end

	def lonlat_present?
		(state.search_params["#{params.ransack_context}within_range"] &&
		state.search_params["#{params.ransack_context}within_range"][0] &&
		state.search_params["#{params.ransack_context}within_range"][1] &&
		state.search_params["#{params.ransack_context}within_range"][1].size > 0) || (state.search_params["#{params.ransack_context}find_in_bounds"])
  end

	def city_changed(val)
		mutate.search_params["#{params.ransack_context}city_eq"] = val

		if val.to_s == ''
			mutate.search_params["#{params.ransack_context}within_range"] = [0, nil]
			mutate.bounds nil
			mutate.search_params["#{params.ransack_context}find_in_bounds"] = nil
		end
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
		bounds = Hash.new(bounds)
		sw_lonlat = [bounds["b"]["b"], bounds["a"]["b"]]
		ne_lonlat = [bounds["b"]["f"], bounds["a"]["f"]]
		mutate.bounds [sw_lonlat, ne_lonlat]
		mutate.search_params["#{params.ransack_context}city_eq"] = short_name
    mutate.search_params["#{params.ransack_context}within_range"] = [state.search_params["#{params.ransack_context}within_range"][0], [Hash.new(location)[:lat], Hash.new(location)[:lng]] ]
  end
end