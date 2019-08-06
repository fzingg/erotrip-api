class AlertIndex < Hyperloop::Component

  state current_page: 1
  state per_page: 30

  state search_params: Hash.new

  def render
    alert_scope = Alert.ransacked(state.search_params)

    div(class: 'row') do
      div(class: 'col-12 col-xl-9 ml-xl-auto main-content alerts') do

				BlockUi(tag: "div", blocking: alert_scope.loading?) do
					paginated_scope = alert_scope.limit(state.per_page).offset((state.current_page - 1) * state.per_page)
          table(class: 'table table-hover mt-4 table-sm table-striped') do
            thead() do
              tr() do
                th(class: "vertical-middle-i") do
                  'Użytkownik'
                end
                th(class: "table-header-resource vertical-middle-i") do
                  MultiSelect(class: 'form-control', placeholder: "Resource", name: 'resource_type_in[]', selection: state.search_params['resource_type_in'] || [], options: [ { label: 'Użytkownik', value: 'User' }, { label: 'Hotline', value: 'Hotline' }, { label: 'Grupa', value: 'Group' }, { label: 'Przejazd', value: 'Trip' } ]).on :change do |e|
                    mutate.search_params['resource_type_in'] = e.to_n
                  end
                end
                th(class: "table-header-amount vertical-middle-i") do
                  'Ilość zgłoszeń'
                end
                th(class: "table-header-buttons") { '' }
              end
            end
            tbody(class: 'text-book') do
              paginated_scope.select { |al| al.reason == 'verification' }.each do |alert|
                tr(class: 'bg-primary-light') do
                  td() { alert.user_descriptor }
                  td() { alert.kind }
                  td() { '-' }
                  td() do
                    button(class: 'btn icon-only btn-sm btn-secondary text-white float-right', type: "button") do
                      i(class: 'ero-search f-s-14')
                    end.on(:click) { |e| open_alert_modal [alert] }
                  end
                end
              end

              paginated_scope.select { |al| al.reason != 'verification' }.group_by { |k| [k.resource_id, k.resource_type]  }.each do |grouping, alerts|
                tr() do
                  td() { alerts.first.user_descriptor }
                  td() { alerts.first.kind }
                  td() { alerts.count.to_s }
                  td() do
                    button(class: 'btn icon-only btn-sm btn-secondary text-white float-right', type: "button") do
                      i(class: 'ero-search f-s-14')
                    end.on(:click) { |e| open_alert_modal alerts }
                  end
                end
              end
            end
          end
				end

				Pagination(
          page: state.current_page,
          per_page: state.per_page,
          total: alert_scope.count
        ).on :change do |e|
          page_changed e.to_n
        end

      end
    end

  end

  def open_alert_modal alerts
    ModalsService.open_modal('AlertShowModal', { size_class: 'modal-lg', alerts: alerts })
  end

  def search_changed terms
    # if terms['sorts'] != state.search_params['sorts'] && state.current_page != 1
      mutate.current_page 1
    # end
    mutate.search_params terms
  end

  def page_changed page
    mutate.current_page page
  end

end