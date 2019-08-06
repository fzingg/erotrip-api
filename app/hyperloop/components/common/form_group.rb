class FormGroup < Hyperloop::Component

  param label:              nil, nils: true
  param error:              nil, nils: true
  param classNames:         '', nils: true
  param hide_error_message: false, nils: true

  def render
    div(class: "form-group #{params.classNames} #{'has-errors' if params.error.present?}") do
      unless params.label == false
        label { params.label.present? ? params.label : " " }
      end

      children.each do |child|
        classes = child.props.className || ''
        classes += ' is-invalid' if params.error.present?
        child.render(class: classes)
      end

      div(class: 'invalid-feedback') { params.error } if params.error.present? && !params.hide_error_message
    end
  end

end