class Slider < Hyperloop::Component

  param selection: 10
  param max: 100
  param min: 0
	param step: nil
	param marks: {}
  param disabled: false
  param className: 'slider'
  param name: "no_name_configured"
  param onChange: nil
	param showMax: false
	param onAfterChange: nil



  def render
		div(class: 'range full') do
      ReactSlider(
        name: params[:name],
        defaultValue: params[:selection].to_i,
				max: params[:max].to_i,
				value: params[:selection].to_i,
        min: params[:min].to_i,
				step: params[:step].to_i,
				marks: `#{params[:marks].to_n}`,
				disabled: params[:disabled].to_n,
				onAfterChange: proc{ |val| on_after_change(val) }
      ).on :change do |e|
        changed(e.to_n)
      end

      if params.showMax == true
  			div(class: 'value-max') do
          "#{params.selection.present? && params.selection > 0 ? params.selection.to_s : ''}"
        end
      end

      input(type: 'hidden', value: params.selection, name: params[:name])
    end
  end

	def changed(val)
    params.onChange.call(val) if params.onChange.present?
	end

	def on_after_change val
		params.onAfterChange.call(val) if params.onAfterChange.present?
	end
end

class SliderSearchWrapper < Hyperloop::Component
	# select proxy params
	param selection: 10
  param max: 100
  param min: 0
	param step: nil
	param marks: {}
  param disabled: false
  param className: 'slider'
  param name: "no_name_configured"
  param onChange: nil
	param showMax: false

	# additional param
	param city_eq: ''

	# additional state
	state selection: 10

	before_receive_props do |next_props|
		if next_props.present? &&  next_props[:selection].present? && next_props[:selection].to_i != state.selection
			mutate.selection next_props[:selection].to_i
		end
	end

	after_mount do
		mutate.selection params[:selection].to_i
	end

	def render
		FormGroup(label: range_text) do
			Slider(
				name: params.name,
				selection: state.selection,
				max: params.max,
				min: params.min,
				step: params.step,
				marks: params.marks,
				disabled: params.disabled,
				onAfterChange: proc { |val| on_after_change(val) }
			).on :change do |e|
				mutate.selection e.to_n
			end
		end
	end

	def on_after_change val
		puts "SENDING AFTER CHANGE TO PARENT SEARCH"
		params.onChange.call(val) if params.onChange.present?
	end

	def range_text
		if !params.disabled && params.city_eq != ''
			if !params.disabled
				if state.selection == 0
					"Całe miasto"
				else
					"W obrębie #{state.selection.floor} km"
				end
			else
				"Cała polska"
			end
		else
			" "
		end
	end
end

