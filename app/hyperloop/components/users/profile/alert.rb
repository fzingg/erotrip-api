class UserAlert < Hyperloop::Component
  include BaseModal

  param resource_id: nil
  param resource_type: nil

  state alert:  {}
  state errors: {}

  state current_file: {
    result: nil,
    src: nil,
    filename: nil,
    filetype: nil,
    error: nil
  }

  state reason: nil

  before_mount do
    if !CurrentUserStore.current_user.blank?
      mutate.alert Hash.new()
    end
  end

  def title
    'Zgłoś użytkownika'
  end

  def render_modal
    span do
      div(class: 'modal-body') do

        div(class: 'mt-4 mb-1 d-flex justify-content-center align-items-center') do
          button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125 #{'invalid-circle' if state.errors['reason'].present?} #{'active' if state.alert['reason'] == 'fiction'}") do
						span() {'Fikcyjne'}
						br()
						span() {'konto'}
					end.on :click do
            mutate.alert['reason'] = 'fiction'
          end
          button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125 #{'invalid-circle' if state.errors['reason'].present?} #{'active' if state.alert['reason'] == 'ad'}") do
            'Reklama'
					end.on :click do
            mutate.alert['reason'] = 'ad'
          end

          button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125 #{'invalid-circle' if state.errors['reason'].present?} #{'active' if state.alert['reason'] == 'other'}") do
            'Inne'
					end.on :click do
            mutate.alert['reason'] = 'other'
          end
        end

        div(class: "mb-3 invalid-feedback #{'force-show' if state.errors['reason'].present?}") do
          "#{state.errors['reason']}"
        end

        FormGroup(error: state.errors['comment']) do
          textarea(placeholder: "Treść #{'(opcjonalnie)' if state.alert['reason'] != 'other'}", name: 'comment', class: "form-control").on :key_up do |e|
            mutate.alert['comment'] = e.target.value
            mutate.errors['comment'] = nil
          end
        end
      end


      div(class: 'modal-footer', style: {justifyContent: 'center', paddingTop: 0}) do
        button(class: 'btn btn-secondary btn-cons mt-3 mb-3', type: "button") do
          'Zgłoś'
        end.on :click do
          report_user
        end
      end
    end
  end

  def report_user
    mutate.alert['resource_id'] = params.resource_id
    mutate.alert['resource_type'] = params.resource_type
    mutate.alert['acting_user'] = CurrentUserStore.current_user

		SaveAlert.run(state.alert)
    .then do |data|
      mutate.blocking false
      `toast.dismiss(); toast.success('Dziękujemy! Zgłoszenie wysłane.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      close
    end
    .fail do |e|
      `console.log('exception: ', e)`
      mutate.blocking false
      `toast.error('Przepraszamy, wystąpił błąd.')`
      if e.class.name.to_s == 'ArgumentError'
        errors = JSON.parse(e.message.gsub('=>', ':'))
        errors.each do |k, v|
          errors[k] = v.join('; ')
        end
        mutate.errors errors
      elsif e.is_a?(Hyperloop::Operation::ValidationException)
        mutate.errors e.errors.message
      end
      {}
    end
  end

end