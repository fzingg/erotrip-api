class AddElementModal < Hyperloop::Component
  include BaseModal

  param group: nil

  def title
    'Dodaj'
  end

  def render_modal
    span do
      div(class: 'add-element-modal-body modal-body text-center') do

        button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125 mt-5") do
          'Hotline'
        end.on :click do
          ModalsService.open_modal('HotlineNewModal', { size_class: 'modal-lg' })
        end

        button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125 mt-5 mb-5") do
          'Przejazd'
        end.on :click do
          ModalsService.open_modal('AddTripModal', { size_class: 'modal-lg' })
        end

      end

      div(class: 'modal-footer') do
        button(class: 'btn btn-outline-primary btn-cons btn-outline-cancel text-gray', type: "button") do
          'Anuluj'
        end.on :click do
          close
        end
      end
    end
  end
end
