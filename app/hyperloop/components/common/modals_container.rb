class ModalsContainer < Hyperloop::Router::Component

  def render
    div(class: 'ero-container') do
      div(class: 'ero-toast-container') do
        if ToastContainer
          ToastContainer(position: 'bottom-center', autoClose: 4000)
        end
      end
      ModalsService.opened_modals.each do |key, value|
        div do
          React.create_element(key.constantize, value['params'])
        end
      end
    end
  end
end

