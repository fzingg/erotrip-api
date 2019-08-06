class TableSelectMenu < Hyperloop::Component
	param options: []
	param selectedOption: nil
	param onMount: nil
	param onOptionSelect: nil
	param optionClassName: ''
	param optionsRefName: nil
	param onOptionsBlur: nil

	after_mount do
		if params.optionsRefName.present?
			refs[params.optionsRefName].focus()
			params.onMount.call(refs[params.optionsRefName]) if params.onMount.present?
		end
	end

	def should_component_update?(new_params_hash, new_state_hash)
		false
  end

	def render
		ul(class: "options", tabIndex: 2, ref: "#{params.optionsRefName}") do
			params.options.each do |option|
				li(class: "option #{'active' if params.selectedOption.present? && option["value"] == params.selectedOption["value"]} #{params.optionClassName if params.optionClassName}") do
					option["label"]
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
		refs[params.optionsRefName].focus()
		params.onOptionSelect.call(option) if params.onOptionSelect.present?
	end
end

class TableSelect < Hyperloop::Component
	param options: []
	param value: nil
	param onChange: nil
	param inputClassName: ""
	param optionClassName: ""
	param optionsVisible: false

	state options_visible: false
	state options_ref_name: nil
	state options_ref: nil

	after_mount do
		mutate.options_ref_name "TableSelect-#{Time.now.to_i}-#{rand(1000)}-#{rand(1000)}"
	end

	def should_component_update?(new_params_hash, new_state_hash)
		# puts "new_params_hash value #{new_params_hash['value']}"
		# puts "new_state_hash #{new_state_hash}"

		# puts "new_state_hash['options_visible'] #{new_state_hash['options_visible']}"
		# puts "state.options_visible #{state.options_visible}"

		# puts "equal? #{new_state_hash['options_visible'] == state.options_visible}"
		new_state_hash['options_visible'] == state.options_visible
  end

	def render
		selected_option = { value: nil, label: "" }
		selected_option = params.options.find{ |option| option["value"] == params.value } if params.options.present? && params.options.size > 0

		div(class: "table-select") do
			(div(class: "#{params.inputClassName} #{'focused' if state.options_visible} fake-input", tabIndex: 1) do
				"#{selected_option.present? ? selected_option["label"] : ''}"
			end.on :focus do |e|
				on_input_focus
			end).on :blur do |e|
				on_input_blur
			end
			if params.options.present? && params.options.size > 0 && (state.options_visible || params.optionsVisible)
				TableSelectMenu(
					options: params.options,
					selectedOption: selected_option,
					onMount: proc{ |options_ref| options_mount(options_ref) },
					optionClassName: params.optionClassName,
					optionsRefName: state.options_ref_name,
					onOptionsBlur: proc{ on_options_blur },
					onOptionSelect: proc{ |opt| on_option_select(opt) }
				)
			end
		end
	end

	def on_input_focus
		mutate.options_visible true
	end

	def options_mount options_ref
		mutate.options_ref options_ref
		focus_options
	end

	def focus_options
		state.options_ref.focus()
		mutate.options_visible true
	end

	def on_input_blur
		hide_options
	end

	def on_options_blur
		mutate.options_visible false
	end

	def hide_options
		mutate.options_visible false
	end

	def on_option_select selected_option
		handle_change selected_option
		hide_options
	end

	def handle_change selected_option
		params.onChange.call(selected_option) if params.onChange.present?
	end
end
