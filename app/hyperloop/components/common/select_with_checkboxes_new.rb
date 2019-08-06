class SelectWithCheckboxesNew < Hyperloop::Component # SelectWithCheckboxes
  param placeholder: ""
  param selection: nil
	param className: ''
	param disabled: false
	param optionsVisible: false
	param maxHeight: ''
  param options: [
    { value: 'one', label: 'Please provide' },
  ]
  param onChange: nil

	state focused: false

	def should_component_update?(new_params_hash, new_state_hash)
		should_update(new_params_hash, new_state_hash)
	end

	def should_update new_params_hash, new_state_hash
		# if new_params_hash[:placeholder] != params[:placeholder]
		# 	true
		# elsif new_params_hash[:selection] != params[:selection]
		# 	true
		# elsif new_params_hash[:className] != params[:className]
		# 	true
		# elsif new_params_hash[:disabled] != params[:disabled]
		# 	true
		# elsif new_params_hash[:optionsVisible] != params[:optionsVisible]
		# 	true
		# elsif new_params_hash[:options] != params[:options]
		# 	true
		# elsif
		# 	true
		# else
		# 	false
		# end
		true
	end

	def render
		selected_option = options.find{ |option| option["value"] == params.selection }

		div(class: "select-new") do
			(input(type: "text", class: "form-control", disabled: (if params.disabled then true else '' end), placeholder: params.placeholder, value: if selected_option.present? then selected_option["label"] else nil end).on :focus do |e|
				mutate.focused true
			end).on :blur do |e|
				mutate.focused false
			end
			ul(class: "select-new-options #{'visible' if state.focused || params.optionsVisible}") do
				options.each do |option|
					li(class: "select-new-option #{'active' if option['value'] == selected_option["value"]}") do
						div(class: "checkbox") { "" }
						div(class: "label") { option["label"] }
					end.on :click do |e|
						e.prevent_default
						e.stop_propagation
						handle_change(option)
					end
				end
			end
		end
  end

	def handle_change(option)
		params.onChange.call(option["value"]) if params.onChange.present?
  end
end

