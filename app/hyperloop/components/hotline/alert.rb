class HotlineAlert < Hyperloop::Component
  include BaseModal

  param resource_id: nil
  param resource_type: nil

  state alert: {  }
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
    mutate.alert Hash.new()
  end

  def title
    'Zgłoś hotline'
  end

  def render_modal
    span do
      div(class: 'modal-body') do

        div(class: 'mt-4 mb-4 d-flex justify-content-center align-items-center') do
          button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125 #{'active' if state.alert['reason'] == 'spam'}") do
            'Spam'
					end.on :click do
            mutate.alert['reason'] = 'spam'
          end
          button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125 #{'active' if state.alert['reason'] == 'ad'}") do
            'Reklama'
					end.on :click do
            mutate.alert['reason'] = 'ad'
          end

          button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125 #{'active' if state.alert['reason'] == 'other'}") do
            'Inne'
					end.on :click do
            mutate.alert['reason'] = 'other'
          end
        end

        FormGroup(error: state.errors['comment']) do
          textarea(placeholder: "Treść (opcjonalnie)", name: 'comment', class: "form-control w-90").on :key_up do |e|
            mutate.alert['comment'] = e.target.value
            mutate.errors['comment'] = nil
          end
        end
      end


      div(class: 'modal-footer', style: {justifyContent: 'center', paddingTop: 0}) do
        button(class: 'btn btn-secondary btn-cons mt-3 mb-3', type: "button") do
          'Zgłoś'
        end.on :click do
          report_hotline
        end
      end
    end
  end

  def report_hotline
    mutate.alert['resource_id'] = params.resource_id
    mutate.alert['resource_type'] = params.resource_type
		mutate.alert['acting_user'] = CurrentUserStore.current_user

		mutate.blocking true

    SaveAlert.run(state.alert)
    .then do |data|
      mutate.blocking false
      `toast.dismiss(); toast.success('Dziękujemy! Zgłoszenie wysłane.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      close
    end
    .fail do |e|
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