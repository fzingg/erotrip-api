class AlertShowModal < Hyperloop::Component
	include BaseModal

	REJECTION_MESSAGES = ["Zdjęcie nie jest prawdziwe", "Zdjęcie jest niewyraźne", "Reklama", "Na zdjęciu mogą być maksymalnie dwie osoby"]
	REJECTION_MESSAGES_SELECT = REJECTION_MESSAGES.each_with_index.map{ |value, index| { label: value, value: index} }

  # state hotline: {  }
  param alerts: []
	state errors: {}
	state rejection_message_index: 0

  state current_page: 1
  state per_page: 2

  state resource: {}

  before_mount do
    mutate.resource params.alerts.first.resource_type.constantize.find(params.alerts.first.resource_id)
  end

  def title
    if params.alerts && params.alerts.count > 0 && params.alerts.first && params.alerts.first.kind
      'Zgłoszenie - ' + params.alerts.first.kind
    else
      ''
    end
  end

  def render_modal
    div(class: 'modal-body text-left p-3 p-md-4') do
      if params.alerts && params.alerts.count > 0 && params.alerts.first && params.alerts.first.resource_type
        case params.alerts.first.resource_type
        when 'Hotline'
          if state.resource.present? && state.resource.created_at.present?
            HotlineHotline(hotline: state.resource, display_buttons: false)
          end
        when 'User'
          UserSquare(user: state.resource, avatar_url: state.resource.try(:avatar_url), show_locker: false, can_redirect: !user.try(:is_private), action_buttons_available: false) unless params.alerts.first.reason == 'verification'
          div(class: 'person') do
            div(class: 'person-photo-wrapper mt-5 mb-5 ml-5 mr-5') do
              img(src: state.resource['verification_photo_url'])
						end if params.alerts.first.reason == 'verification'

          end
        when '2'
        else
        end

        table(class: 'table table-striped table-sm table-hover text-left') do
          thead() do
            tr() do
              th() { 'Kto' }
              th() { 'Kiedy' }
              th() { 'Typ' }
              th() { 'Treść' }
            end
          end
          tbody() do

            params.alerts.drop((state.current_page - 1) * state.per_page).first(state.per_page).each do |alert|
              tr() do
                td() { alert.reported_by['profile_descriptor'] }
                td() { alert.created_at.strftime('%d.%m.%Y') }
                td() { alert.reason_translated }
                td() { alert.comment || '-' }
              end
            end

          end
        end

        Pagination(
          page: state.current_page,
          per_page: state.per_page,
          total: params.alerts.count
        ).on :change do |e|
          mutate.current_page e.to_n
        end
      else
      end
    end.while_loading do
      p() { '' }
    end

		div(class: "ml-4 mr-4") do
			FormGroup(label: 'Powód odrzucenia', error: nil) do
				Select(placeholder: "", clearable: false, backspaceRemoves: false, deleteRemoves: false, options: REJECTION_MESSAGES_SELECT, selection: state.rejection_message_index, className: "form-control").on :change do |e|
					mutate.rejection_message_index e.to_n
				end
			end
		end if params.alerts.first.reason == 'verification'

		BlockUi(tag: "div", blocking: state.blocking, class: "modal-footer pl-3 pl-md-4 pb-3 pb-md-4 pr-3 pr-md-4") do
			div(class: "d-flex justify-content-between ea-flex-1") do
				button(class: 'btn btn-primary btn-cons', type: "button") do
					'Zaakceptuj'
				end.on :click do
					process_alerts true
				end

				button(class: 'btn btn-secondary btn-cons', type: "button") do
					'Odrzuć'
				end.on :click do
					process_alerts false
				end
			end
		end

  end

  def process_alerts accept=false
    if params.alerts.count == 1 && params.alerts.first.reason == 'verification'
      ProcessVerification.run({ user_id: state.resource.id, verify: accept, alert_ids: params.alerts.map(&:id), message: REJECTION_MESSAGES[state.rejection_message_index] })
      .then do |data|
        # puts data
        close
      end
      .fail do |e|
        # puts 'fail'
        # puts e
      end
    else
      ProcessAlerts.run({ alert_ids: params.alerts.map(&:id), accept: accept })
      .then do |data|
        # puts data
        close
      end
      .fail do |e|
        # puts 'fail'
        # puts e
      end
    end
  end

end