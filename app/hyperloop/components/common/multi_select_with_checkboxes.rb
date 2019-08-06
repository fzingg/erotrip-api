class MultiSelectWithCheckboxesMenu < Hyperloop::Component
	param options: []

	param onMount: nil
	param onOptionSelect: nil
	param optionsRefName: nil
	param onOptionsBlur: nil
	param maxHeight: ''

	param show_strict_checkbox_in_menu: false, nils: true
	param is_strict_checked: false
	param onStrictChecked: nil, nils: true

	state menu_opened: false
	state perfectMatchChecked: false

	after_mount do
		if params.optionsRefName.present?
			params.onMount.call(refs[params.optionsRefName]) if params.onMount.present?
		end
		if params.is_strict_checked.present?
			mutate.perfectMatchChecked params.is_strict_checked
		end
	end

	def render
		ul(class: "multi-selectchkbox-new-options #{params.maxHeight}", ref: "#{params.optionsRefName}") do

			div(class: "#{'d-none' if !params.show_strict_checkbox_in_menu}") do
				li(class: "multi-selectchkbox-new-option strict-match #{'active' if state.perfectMatchChecked }") do
					div(class: "checkbox") { "" }
					div(class: "label") { "Szukających tylko" }
				end.on :click do |e|
					mutate.perfectMatchChecked !state.perfectMatchChecked
					params.onStrictChecked.call(state.perfectMatchChecked) if params.onStrictChecked.present?
				end

				div(class: 'divider mb-2') do
				end
			end

			params.options.each do |option|
				li(class: "multi-selectchkbox-new-option #{'active' if option['selected'] == true}") do
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

class MultiSelectWithCheckboxes < Hyperloop::Component
	param placeholder: ""
  param selection: []
	param className: nil
	param disabled: false
	param optionsVisible: false
	param maxHeight: ''
	param hideAfterSelect: false
  param options: [
    { value: 'one', label: 'Please provide' },
  ]
  param onChange: nil
  param show_strict_checkbox: false, nils: true
  param onStrictCheckedFromMultiselect: false, nils: true

	state options_ref_name: nil
	state options_ref: nil
	state menu_opened: false
	state strict_checked: false

	after_mount do
		mutate.options_ref_name "MultiSelectWithCheckboxes-#{Time.now.to_i}-#{rand(1000)}-#{rand(1000)}"
		puts "options #{params.options}"
	end

	def render
		currently_selected = params.selection || []
		options = []
		options = params.options.map{ |option| option.merge({ "selected": currently_selected.include?(option["value"]) }) } if params.options.present? && params.options.size > 0
		selected_options = options.select{ |option| option["selected"] == true }

		div(class: "multi-selectchkbox-new noselect tabIndex", tabIndex: -1) do
			div(class: "form-control fake-input #{'disabled' if params.disabled} #{'empty' if (selected_options.blank? || selected_options.size == 0)} #{'focused' if state.menu_opened}") do
				"#{if selected_options.size > 0 then selected_options.map{ |o| o["label"] }.join(", ") else params.placeholder end}"
			end.on :click do |e|
        on_input_click
      end
			if (state.menu_opened || params.optionsVisible)
				MultiSelectWithCheckboxesMenu(
					options: options,
					onMount: proc{ |options_ref| options_mount(options_ref) },
					onOptionSelect: proc { |option| on_option_select(option) },
					optionsRefName: state.options_ref_name,
					maxHeight: params.maxHeight,
					onOptionsBlur: proc { on_options_blur },

					show_strict_checkbox_in_menu: params.show_strict_checkbox,
					is_strict_checked: state.strict_checked,
					onStrictChecked: proc { |val| strictly_checked(val) }
				)
			end
		end.on :blur do |e|
      on_select_blur
    end
	end

	def on_input_click
		mutate.menu_opened !state.menu_opened
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

	def on_option_select option
		state.options_ref.focus()
		handle_change option
		hide_options if params.hideAfterSelect.present? && params.hideAfterSelect == true
	end

	def strictly_checked val
		mutate.strict_checked val
		params.onStrictCheckedFromMultiselect.call(val) if params.onStrictCheckedFromMultiselect.present?
	end

	def handle_change option
		result = nil
		if option["selected"] == true
			result = (params.selection || []) - [option["value"]]
		else
			result = (params.selection || []) + [option["value"]]
		end
		params.onChange.call(result) if params.onChange.present?
  end
end

