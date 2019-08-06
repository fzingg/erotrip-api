class Pluralized < Hyperloop::Component

  param count:        0
  param className:    ''
  param count_class:  'mr-1' #'text-primary mr-2'
  param text_class:   '' #'text-gray'

  param :one
  param few:    nil, nils: true
  param many:   nil, nils: true
  param other:  nil, nils: true

  def render
    div(class: params[:className]) do
      span(class: "#{params.count_class}") { params.count.to_s }
      span(class: params.text_class) { " #{proper_word}" }
    end
  end

  def proper_word
    if params.count == 0
      params[:other] || params[:many] || params[:one]
    elsif params.count == 1
      params[:one]
    elsif params.count < 5
      params[:few] || params[:many] || params[:one]
    else
      params[:many] || params[:one]
    end
  end
end
