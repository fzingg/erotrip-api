class SelectMenu < Hyperloop::Component
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
		ul(class: "select-new-options #{params.maxHeight}", ref: "#{params.optionsRefName}") do
			params.options.each do |option|
				li(class: "select-new-option #{'active' if (params.selectedOption.present? && option['value'] == params.selectedOption["value"])}") do
					option["label"].to_s
				end.on :click do |e|
					option_selected(option)
				end
			end
		end
	end

	def option_selected option
		params.onOptionSelect.call(option) if params.onOptionSelect.present?
	end
end

class Select < Hyperloop::Component
	# These params are here to not break any code that is already using old select API
	param name: nil, nils: true
	param clearable: nil, nils: true
	param backspaceRemoves: nil, nils: true
	param deleteRemoves: nil, nils: true
	param drop_up: false, nils: true

	# Good params
	param placeholder: ""
	param selection: nil
	param className: nil
	param disabled: false, nils: true
	param optionsVisible: false, nils: true
	param maxHeight: '', nils: true # h-100, h-150, h-200, h-250, h-300
	param options: [
		{ value: 'one', label: 'Please provide' },
	]
	param onChange: nil
	state options_ref_name: nil
	state options_ref: nil
	state menu_opened: false

	state input_just_blurred: false
	state options_just_blurred: false

	after_mount do
		mutate.options_ref_name "Select-#{Time.now.to_i}-#{rand(1000)}-#{rand(1000)}"
	end

	def render
		selected_option = params.options.find{ |option| option["value"] == params.selection }

		div(class: "select-new noselect", tabIndex: -1) do
			div(class: "#{params.className || 'form-control'} fake-input #{'disabled' if params.disabled} #{'empty' if selected_option.blank?} #{'focused' if state.menu_opened}") do
				"#{if selected_option.present? then selected_option["label"].to_s else params.placeholder end}"
			end.on :click do |e|
				on_input_click
			end
			if (state.menu_opened || params.optionsVisible)
				SelectMenu(
					options: params.options,
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
		params.onChange.call(option["value"]) if params.onChange.present?
	end
end

