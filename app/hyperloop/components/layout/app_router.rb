class AppRouter < Hyperloop::Router
	history :browser

  state libs_logged: false

  before_mount do
    puts "ACTING USER ID: #{Hyperloop::Application.acting_user_id}"
    if CurrentUserStore.current_user_id != Hyperloop::Application.acting_user_id.try(:to_i)
      CurrentUserStore.current_user_id! Hyperloop::Application.acting_user_id.to_i
    end
    CurrentUserStore.init_current_user
  end

  after_mount do
    # puts "toast #{toast}"
    # `Toast.success('Zdjęcie weryfikacyjne zostało usunięte.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800000 })`
    # Toast.success('Zdjęcie weryfikacyjne zostało usunięte.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800000 })

    HotlineTimeStore.init
    # Hyperloop.connect_session
		ProcessLogin.on_dispatch do |params|
      puts "--> ProcessLogin.on_dispatch <--"
      # CurrentUserStore.update_session_connection!(params.to_h['old_session'], params.to_h['new_session']) if params.to_h && params.to_h['old_session'] && params.to_h['new_session']
			CurrentUserStore.current_user_id! params.to_h['response']['id'] if params.to_h && params.to_h['response'] && params.to_h['response']['id']
      Hyperloop.connect("User-#{params.to_h['response']['id']}")
      Hyperloop.connect(Admin) if params.to_h['response']['is_admin']
		end

    ProcessRegistration.on_dispatch do |params|
      puts "--> ProcessRegistration.on_dispatch <--"
      CurrentUserStore.current_user_id! params.to_h['response']['id'] if params.to_h && params.to_h['response'] && params.to_h['response']['id']
      Hyperloop.connect("User-#{params.to_h['response']['id']}")
      Hyperloop.connect(Admin) if params.to_h['response']['is_admin']
    end
    ProcessLogout.on_dispatch do |params|
      puts "--> ProcessLogout.on_dispatch <--"
      puts params.inspect
      # Hyperloop.disconnect("User-#{CurrentUserStore.current_user_id}")
      # Hyperloop.disconnect(Admin)
      CurrentUserStore.current_user_id! nil
      # CurrentUserStore.update_session_connection!(params.to_h['old_session'], params.to_h['new_session']) if params.to_h && params.to_h['old_session'] && params.to_h['new_session']
      if React::IsomorphicHelpers.on_opal_client?
        `window.location.href = window.location.origin + "/users"`
      end
      # Hyperloop.disconnect("User-#{CurrentUserStore.current_user_id}")
      # Hyperloop.disconnect(Admin)
		end

    Notify.on_dispatch do |params|
      puts "received in APP ROUTER: #{params.inspect}"
      puts "acting_user: #{CurrentUserStore.current_user.inspect}"
    end

    if RUBY_ENGINE == 'opal'

  		`
  		var erotripLogOutTimeout = null;
  		document.body.onclick = function() {
  			if(erotripLogOutTimeout) {
  				clearTimeout(erotripLogOutTimeout);
  			}

  			erotripLogOutTimeout = setTimeout(function() {
  				#{log_out_user_if_session_exists}
  			}, 900000);
  		}
  		`
    end
	end

  # before_update do
  #   hide_loader
  # end

	def log_out_user_if_session_exists
		if CurrentUserStore.current_user_id
			ProcessLogout.run
			.then do
				# `toast.dismiss(); toast.success('Wylogowaliśmy Cię z EroTrip z powodu braku aktywności.')`
			end
		end
	end

  def self.push path, search_query = nil
    if React::IsomorphicHelpers.on_opal_client?
      proper_path = path
      proper_path += "?#{search_query}" if search_query.present?
      history.push(proper_path)
    end
  end

	def self.replace path, search_query = nil
		if React::IsomorphicHelpers.on_opal_client?
			history.replace({ path: path, search: search_query })
		end
	end

  def open_messages_modal
    if CurrentUserStore.current_user.blank?
      ModalsService.open_modal('RegistrationModal', { callback: proc { AppRouter.push params.to } })
    else
      ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static'})
    end
  end

  def hide_loader_if_should
    after(0.5) do
      if !Commons.is_initially_loaded && ReactiveRecord::WhileLoading.quiet?
        # `if (!$('.app-loader.minor').hasClass('hide-me') > 0) { $('.app-loader.minor').addClass('hide-me').delay(500).addClass('hidden'); }`
        Commons.loaded_initially
      end
    end
  end

  route do

    @main_div_element = div do
      # `if (!$('.app-loader.minor').hasClass('hide-me') > 0) { $('.app-loader.minor').addClass('hide-me').delay(500).addClass('hidden'); }`
      if !Commons.is_initially_loaded && ReactiveRecord::WhileLoading.quiet?
        hide_loader_if_should
      end
      # puts "@main_div_element.try(:loading?), #{@main_div_element.try(:loading?)}"

      # div(class: "app-loader hidden #{'hide-me' if Commons.is_initially_loaded}") do
      #   div do
      #     img(src: '/assets/logo_obrys_v2.png')
      #     div(class: "animated-dots") do
      #       span {'.'}
      #       span {'.'}
      #       span {'.'}
      #     end

      #   end
      # end

      # due to bug while importing external packages we need to log them before first use
      # if !state.libs_logged
      #   # puts "#{ReactDOM}, #{React}, #{ReactSelect}, #{ReactSlider}, #{ReactRange}, #{DropNCrop}, #{GooglePlacesAutocomplete}, #{GeocodeByAddress}, #{ReactTooltip}, #{ToastContainer}, #{BlockUi}, #{GoogleMapReact}, #{Datetime}, #{BootstrapMultiSelect}"
      #   mutate.libs_logged true
      # end

      Route("/") { |m, l, h| MobileHeader(match: m, location: l, history: h) }

      Route("/") { |m, l, h| Sidebar(match: m, location: l, history: h) }
      # Route('/', exact: false, mounts: Sidebar)

      Route("/") { |m, l, h| MobileBar(match: m, location: l, history: h) }
      # Route('/', exact: false, mounts: Sidebar)

      div(class: "container main-container") do
        Route("/") { |m, l, h| Header(match: m, location: l, history: h) }
        # Route('/', exact: false, mounts: Header)


        Route("/") { |m, l, h| HotlineCarousel(match: m, location: l, history: h) }

        Route('/profile-not-found') { |m, l, h| ProfileNotFound(match: m, location: l, history: h) }
        Route('/profile/:user_id') { |m, l, h| Profile(match: m, location: l, history: h) }
        # Route('/profile-edit') { |m, l, h| ProfileEdit(match: m, location: l, history: h) }
        # Route('/profile-settings') { |m, l, h| ProfileSettings(match: m, location: l, history: h) }

        # main routes
        Route("/users", exact: true) { |m, l, h| UsersIndex(match: m, location: l, history: h) }
        # Route('/', exact: true, mounts: UsersIndex)

        # Route("/users") { |m, l, h| UsersIndex(match: m, location: l, history: h) }
        # Route('/users', mounts: UsersIndex)
        Route('/trips') { |m, l, h| Trips(match: m, location: l, history: h) }
        Route('/my-trips') { |m, l, h| MyTrips(match: m, location: l, history: h) }
        Route('/new-trips') { |m, l, h| NewTripsIndex(match: m, location: l, history: h) }
        Route("/groups", exact: true) { |m, l, h| GroupsIndex(match: m, location: l, history: h) }

        Route("/groups/:id") { |m, l, h| GroupsShow(match: m, location: l, history: h) }
        # Route('/groups', mounts: GroupsShow) #temporarily
        Route("/hotline") { |m, l, h| HotlineIndex(match: m, location: l, history: h) }

        Route("/alerts") { |m, l, h| AlertIndex(match: m, location: l, history: h) }
        # Route('/hotline', mounts: Hotline)
        Route('/messages') { |m, l, h| Messenger(match: m, location: l, history: h) }
        # Route('/notifications', mounts: Notifications)
        Route('/want-to-meet') { |m, l, h| WantToMeetIndex(match: m, location: l, history: h) }
        # Route('/peeper', mounts: Peeper)
        Route('/new-people') { |m, l, h| NewPeople(match: m, location: l, history: h) }
        Route('/peepers') { |m, l, h| PeepersIndex(match: m, location: l, history: h) }
        # Route('/new-trips', mounts: NewTrips)
        Route('/unlocks') { |m, l, h| UnlocksIndex(match: m, location: l, history: h) }
        # Route('/anonymous', mounts: Anonymous)


        Route("/") { |m, l, h| Footer(match: m, location: l, history: h) }
        # Route('/', exact: false, mounts: Footer)
			end
      Route("/") { |m, l, h| ModalsContainer(match: m, location: l, history: h) }
      # Route('/', exact: false, mounts: ModalsContainer)
    end

    # .while_loading do
    #   # hide_loader
    #   puts "initially loaded #{Commons.is_initially_loaded}"
    #   if Commons.is_initially_loaded
    #     @main_div_element
    #   else
    #     div(class: "app-loader #{'hide-me' if Commons.is_initially_loaded}") do
    #       div do
    #         'ŁADOWANIE'
    #       end
    #     end
    #   end
    # end

  end
end