class MultiSelectWithCheckboxesNew < Hyperloop::Component
  param placeholder: ""
  param selection: []
	param className: ''
	param disabled: false
	param optionsVisible: false
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
		currently_selected = params.selection || []
		options = []
		options = params.options.map{ |option| option.merge({ "selected": currently_selected.include?(option["value"]) }) } if params.options && params.options.size > 0
		selected_options = options.select{ |option| option["selected"] == true }

		div(class: "multi-selectchkbox-new") do
			(input(type: "text", class: "form-control", disabled: (if params.disabled then true else '' end), placeholder: params.placeholder, value: if selected_options.size > 0 then selected_options.map{ |o| o["label"] }.join(", ") else nil end).on :focus do |e|
				mutate.focused true
			end).on :blur do |e|
				mutate.focused false
			end
			ul(class: "multi-selectchkbox-new-options #{'visible' if state.focused || params.optionsVisible}") do
				options.each do |option|
					li(class: "multi-selectchkbox-new-option #{'active' if option['selected'] == true}") do
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
		result = nil
		if option["selected"] == true
			result = (params.selection || []) - [option["value"]]
		else
			result = (params.selection || []) + [option["value"]]
		end
		params.onChange.call(result) if params.onChange.present?
  end
end

