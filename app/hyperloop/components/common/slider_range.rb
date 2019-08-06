class SliderRange < Hyperloop::Component

  param selection: [20, 30]
  param name: "no_name_configured[]"
  param min: 18
  param max: 50
  param onChange: nil
	param disabled: false
  param className: 'slider-range'
  param onAfterChange: nil


  def render
    div(class: 'range') do
      div(class: 'value-min') do
        "#{params.selection.present? ? params.selection[0] : ''}"
      end

      ReactRange(
        name: params[:name],
        min: params[:min].to_i,
				max: params[:max].to_i,
				disabled: params[:disabled].to_n,
        defaultValue: (params[:selection] || []).map(&:to_i).to_n,
				value: (params[:selection] || []).map(&:to_i).to_n,
				onAfterChange: proc{ |val| on_after_change(val) }
      ).on :change do |e|
        changed(e)
      end

			div(class: 'value-max') do
				if params.selection.present? && params.selection[1] >= 50
					"#{params.max.to_s}+"
				else
					"#{params.selection.present? ? params.selection[1] : ''}"
				end
      end

      input(type: 'hidden', value: (params.selection || [])[0], name: params[:name])
      input(type: 'hidden', value: (params.selection || [])[1], name: params[:name])
    end
  end

	def changed(val)
    params.onChange.call(Array.new(val.to_n)) if params.onChange.present?
	end

	def on_after_change(val)
		params.onAfterChange.call(Array.new(val.to_n)) if params.onAfterChange.present?
	end
end

class SliderRangeSearchWrapper < Hyperloop::Component
	# proxy params
	param name: 'age[]'
	param selection: []
	param min:  18
	param max: 50
	param onChange: nil

  param disabled: false
  param className: 'slider-range'

	# additional state
	state selection: []

	before_receive_props do |new_params|
		if new_params.present? && new_params[:selection].present? && new_params[:selection] != state.selection
			mutate.selection new_params[:selection]
		end
	end

	def render
		SliderRange(
			name: param.name,
			selection: state.selection,
			min:  params.min,
			max: params.max,
			onAfterChange: proc { |val| on_after_change(val) },
      disabled: params.disabled,
      className: params.className
		).on :change do |e|
			mutate.selection e.to_n
		end
	end

	def on_after_change val
		params.onChange.call(val) if params.onChange.present?
	end
end
