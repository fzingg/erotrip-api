class SelectWithCheckboxesMenu < Hyperloop::Component
  param options: []
  param selectedOption: nil
  param onMount: nil
  param onOptionSelect: nil
  param optionsRefName: nil
  param onOptionsBlur: nil
  param maxHeight: ''

  after_mount do
    if params.optionsRefName.present?
      params.onMount.call(refs[params.optionsRefName]) if params.onMount.present?
    end
  end

  def render
    ul(class: "selectchkbox-new-options #{params.maxHeight}", ref: "#{params.optionsRefName}") do
      params.options.each do |option|
        li(class: "selectchkbox-new-option #{'active' if (params.selectedOption && params.selectedOption["value"] == option["value"])}") do
          div(class: "checkbox") { "" }
          div(class: "label") { option["label"].to_s }
        end.on :click do |e|
          e.prevent_default
          e.stop_propagation
          option_selected(option)
        end
      end
    end.on :blur do |e|
      params.onOptionsBlur.call() if params.onOptionsBlur.present?
    end
  end

  def option_selected option
    params.onOptionSelect.call(option) if params.onOptionSelect.present?
  end
end


class SelectWithCheckboxes < Hyperloop::Component
  param placeholder: ""
  param selection: nil
  param className: nil
  param disabled: false, nils: true
  param optionsVisible: false
  param maxHeight: ''
  param options: [
    { value: 'one', label: 'Please provide' },
  ]
  param onChange: nil

  state options_ref_name: nil
  state options_ref: nil
  state menu_opened: false

  after_mount do
    mutate.options_ref_name "SelectWithCheckboxes-#{Time.now.to_i}-#{rand(1000)}-#{rand(1000)}"
  end

  def render
    options = params.options.present? && params.options.size > 0 ? params.options : []
    selected_option = params.options.find{ |option| option["value"] == params.selection } if params.options.present?

    div(class: "selectchkbox-new noselect", tabIndex: -1) do
      div(class: "fake-input #{params.className || 'form-control'} #{'disabled' if params.disabled} #{'empty' if selected_option.blank?} #{'focused' if state.menu_opened}") do
        "#{if selected_option.present? then selected_option["label"] else params.placeholder end}"
      end.on :click do |e|
        on_input_click
      end
      if (state.menu_opened || params.optionsVisible)
        SelectWithCheckboxesMenu(
          options: options,
          selectedOption: selected_option,
          onMount: proc{ |options_ref| options_mount(options_ref) },
          onOptionSelect: proc { |option| on_option_select(option) },
          optionsRefName: state.options_ref_name,
          maxHeight: params.maxHeight,
          onOptionsBlur: proc { on_options_blur }
        )
      end
    end.on :blur do |e|
      on_select_blur
    end
  end

  def on_input_click
    mutate.menu_opened !state.menu_opened
    puts "on_input_click #{state.menu_opened}"
  end

  def options_mount options_ref
    mutate.options_ref options_ref
  end

  def on_select_blur
    puts "on_select_blur"
    mutate.menu_opened false
  end

  def hide_options
    mutate.menu_opened false
  end

  def on_option_select selected_option
    puts "selected_option #{selected_option}"
    handle_change selected_option
    hide_options
  end

  def handle_change(option)
    result = nil

    if option.present? && option["value"] != params.selection
      result = option["value"]
    end
    params.onChange.call(result) if params.onChange.present?
  end
end

