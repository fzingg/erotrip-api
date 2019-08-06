class MobileBar < Hyperloop::Router::Component

  def render
    div(class: 'mobile-bar') do
      ul(class: 'mobile-bar-menu') do
        li(class: 'menu-item ml-3') do
          EroNavLink(to: '/users', active_class: 'active', exact: true) do
            div(class: 'mobile-bar-icon-wrapper') do
              i(class: 'ero-users f-s-18  ')
              span {'Osoby'}
            end.on :click do |e|
              # e.stop_propagation
              SidebarStore.set_state false
            end
          end
        end

        li(class: 'menu-item') do
          EroNavLink(to: '/trips', active_class: 'active') do
            div(class: 'mobile-bar-icon-wrapper') do
              i(class: 'ero-trips f-s-18  ')
              span {'Przejazdy'}
            end.on :click do |e|
              # e.stop_propagation
              SidebarStore.set_state false
            end
          end
        end

        li(class: 'menu-item') do
          button(class: 'btn btn-container text-white white-border secondary-bg', type: 'button') do
            i(class: 'ero-cross f-s-18')
          end.on :click do |e|
            # e.stop_propagation
            open_add_element_modal
          end
        end

        li(class: 'menu-item') do
          EroNavLink(to: '/hotline', active_class: 'active') do
            div(class: 'mobile-bar-icon-wrapper') do
              i(class: 'ero-hotline f-s-18  ')
              span {'Hotline'}
            end.on :click do |e|
              # e.stop_propagation
              SidebarStore.set_state false
            end
          end
        end

        li(class: 'menu-item mr-3') do
          EroNavLink(to: '/groups', active_class: 'active') do
            div(class: 'mobile-bar-icon-wrapper') do
              i(class: 'ero-groups f-s-18 ')
              span {'Grupy'}
            end.on :click do |e|
              # e.stop_propagation
              SidebarStore.set_state false
            end
          end
        end
      end
    end.on :click do |e|
      e.stop_propagation
    end
  end

  def open_add_element_modal
    ModalsService.open_modal('AddElementModal', { size_class: 'modal-md' })
  end

end
