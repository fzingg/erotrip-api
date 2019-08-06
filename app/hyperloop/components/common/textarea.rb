class Textarea < Hyperloop::Component
  param value: ''
  param onChange: nil, nils: true
  param placeholder: '', nils: true
  param class_name: '', nils: true
  param max_length: 140, nils: true
  param name: 'content', nils: true

  state value: ''
  # state remove_timeout: nil

  after_mount do
    mutate.value params.value
  end

  def render

    div(class: "textarea-container") do
      textarea(
      class: "form-control #{params.class_name || ''}",
      placeholder: params.placeholder,
      name: params.name,
      maxLength: params.max_length,
      defaultValue: params.value,
      ).on :input do |e|
        e.target.value = e.target.value.to_s[0,140]
        mutate.value e.target.value
        params.onChange.call(e.target.value)

        # value_copy = e.target.value.dup
        # if state.remove_timeout
        #   state.remove_timeout.abort
        # end
        # mutate.remove_timeout(after(0.3) do
        #   params.onChange.call(value_copy) if params.onChange.present?
        # end)
      end

      div(class: 'text-right mt-1 float-right') do
        span(class: "text-regular #{'text-danger' if (state.value || '').size >= 140}") { "#{140 - (state.value || '').size}" }
      end
    end

  end
end
