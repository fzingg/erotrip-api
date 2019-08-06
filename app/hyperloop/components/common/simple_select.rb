class SimpleSelect < Hyperloop::Component

  param placeholder: ""
  param selection: ''
  param name: "no_name_configured"
  param className: ''
  param onChange: nil
  param onKeyUp: nil
  param scrollMenuIntoView: true
  param clearable: true
  param backspaceRemoves: true
  param deleteRemoves: true
  param disabled: false

  param options: [
    { value: 'one', label: 'Please provide' },
    { value: 'two', label: 'some options' }
  ]

  def proper_options(opts=[])
    if CurrentUserStore.current_user.present?
      result = opts.dup
    else
      result = []
      opts.each do |opt|
        result.push opt if !opt['only_for_user']
      end
    end
    result
  end


  def render
    ReactSelect(
      name: params[:name],
      className: params['className'],
      value: params[:selection].to_n,
      options: proper_options(params[:options]).to_n,
      placeholder: params[:placeholder],
      clearable: params[:clearable],
      backspaceRemoves: params[:backspaceRemoves],
      deleteRemoves: params[:deleteRemoves],
      disabled: params[:disabled],
      scrollMenuIntoView: params[:scrollMenuIntoView],
      multi: false,
      onInputChange: proc { |e| keyup(e) }
    ).on :change do |e|
      changed(e)
    end
  end

  def keyup(val)
    params.onKeyUp.call(val) if params.onKeyUp.present?
  end

  def changed(val)
    choice = Hash.new(val.to_n)
    if choice['auth'].present? && choice['auth'] == true && CurrentUserStore.current_user.blank?
      ModalsService.open_modal('RegistrationModal', callback: proc { |result| trigger_on_change(choice['value']) if result.present? && result == true})
    else
      trigger_on_change(choice['value'])
    end
  end

  def trigger_on_change(val = '')
    params.onChange.call(val) if params.onChange.present?
  end
end

