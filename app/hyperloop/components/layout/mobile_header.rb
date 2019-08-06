class MobileHeader < Hyperloop::Router::Component

  state user: {}
  state user_id: 0

  before_mount do
    get_profile
  end

  before_receive_props do |next_props|
    user_id = location.pathname.split("/")[2]
    mutate.user_id user_id
  end

  after_update do
    user_id = location.pathname.split("/")[2]

    if state.user_id != user_id
      mutate.user_id user_id
      puts "profile changed to id: #{user_id}"
    end
  end

  def render
    div(class: "navbar d-md-none") do
      button(class: "btn btn-outline-primary btn-outline-gray icon-only with-label more", type: "button") do
        i(class: "ero-menu")
        NotificationDot()
      end.on :click do
        SidebarStore.set_state true
      end

      EroNavLink(to: '/users', active_class: 'active', exact: true) do
        img(src: '/assets/logo_obrys_v2.png')
      end

      if url_matches_profile location.pathname
        if CurrentUserStore.current_user_id == state.user_id.to_i
          span(class: "btn btn-outline-primary btn-outline-gray btn-settings icon-only text-primary") do
            # i(class: "#{if SettingsStore.is_open then 'ero-user' else 'ero-settings' end} f-s-20")
            EroLink(to: "/profile/#{CurrentUserStore.current_user_id}#{location.pathname.end_with?('/settings') ? '' : '/settings'}") do
              i(class: "#{location.pathname.end_with?('/settings') ? 'ero-user' : 'ero-settings'} f-s-20")
            end
          end
          # .on :click do |e|
          #   SettingsStore.set_state !SettingsStore.is_open
          # end
        else
          button(class: "btn btn-outline-gray btn-outline-primary icon-only btn-report-user-mobile", type: "button") do
            span(class: "d-inline-block d-none") {'!'}
          end.on(:click) { report_user state.user_id }
        end
      else
        MobileSearchBarButton(
          classNames: "#{'vhidden' if !MobileSearchButtonStore.is_visible} #{'disabled' if !MobileSearchButtonStore.is_visible}", i: 'ero-search bold').on :click do
          MobileSearchButtonStore.trigger
        end
      end

    end
  end

  def report_user user_id
    ModalsService.open_modal('UserAlert', { size_class: 'modal-md', resource_id: user_id, resource_type: 'User' })
  end

  def get_profile user_id_override
    if url_matches_profile location.pathname
      user_id = location.pathname.split("/")[2]
      mutate.user_id user_id

      # puts "BEFORE GET PROFILE FROM HEADER , parsed user_id: #{user_id}"
      # GetProfile.run({user_id: (user_id_override || user_id)})
      # .then do |response|
      #   puts "GOT PROFILE FROM HEADER #{response.inspect}"
      #   mutate.user User.find(response[:id])
      #   after(0) {
      #     mutate.user User.find(response[:id])
      #   }
      # end
      # .fail do |e|
      #   puts "ERROR GETTING PROFILE FROM HEADER  #{e.inspect}"
      #   history.replace('/profile-not-found')
      # end
    end
  end

  def url_matches_profile pathname
    (pathname.to_s).include? "profile/"
  end

end
