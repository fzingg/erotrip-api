class AlertAlert < Hyperloop::Component

  param :alert

  def render
    div(class: 'ea-flex ea-align-center') do

      div(class: 'text') do
        div(class: 'profile-info-wrapper') do
          div(class: 'profile-info') do
            div(class: 'profile-info-upper') do
              h4(class: 'mb-0') do
                span { "#{params.alert.resource_type} - #{params.alert.reason}" }
                # span { params.alert.user.name + ', '}
                # span(class: 'text-gray') {'18'}
              end
            end
            div(class: 'profile-info-lower mb-3') do
              span(class: 'text-gray') {'Zgłoszono '}
              span(class: 'text-gray') {'2 dni temu przez '}
              span(class: 'text-gray') { params.alert.reported_by.name }
              # span(class: 'text-gray') { params.alert.resource['id'].to_s }
              # span(class: 'text-gray') { params.alert.resource['content'] }
            end
          end
        end

        p(class: 'text-book text-gray') { params.alert.comment }

      end
    end
  end
end