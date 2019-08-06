class TripSingle < Hyperloop::Component

  PRIVACY_OPTIONS = [
    {label: 'Publiczny', value: 'is_public'},
    {label: 'Prywatny',  value: 'is_private'}
  ]

  param trip: nil
  param :about_to_remove
  param :on_remove_init
  state :formatted_date
  state set_timeout: nil


  before_mount do
    # unless React::IsomorphicHelpers.on_opal_client?
    #   puts " #{params.trip.try(:arrival_time)}"
    #   if params.trip.arrival_time.present?
    #     set_formatted_date(params.trip.arrival_time)
    #   end
    # end
  end

  after_mount do
    # if React::IsomorphicHelpers.on_opal_client?
    #   if params.trip.arrival_time.present?
    #     set_formatted_date(params.trip.arrival_time)
    #   end
    # end
    # `var midnightDate = new Date();
    # midnightDate.setHours(24,0,0,0);
    # var diff = midnightDate.getTime() - (new Date()).getTime();
    # var interval = setTimeout(function(){
    #   #{set_formatted_date(params.trip.arrival_time)}
    # }, diff + 2500);`
    # mutate.set_timeout `interval`
  end

  before_unmount do
    # `clearTimeout(#{state.set_timeout})`
    # mutate.set_timeout nil
  end


  before_receive_props do |new|
    # if new[:trip][:arrival_time].present? && !state.formatted_date.present?
    #   set_formatted_date(new[:trip][:arrival_time])
    # end
  end

  def get_formatted_date date
    # if React::IsomorphicHelpers.on_opal_client?
  	 #  `var newDate = new Date(#{date.to_s})
    #   var result = null;

    #   if (newDate.toDateString() == new Date(new Date().setDate(new Date().getDate() -1 )).toDateString()) {
  		#  	result = { prefix: "Wczoraj, ", datetime: #{date.strftime('%H:%M ')} }
    #   } else if (new Date().toDateString() === newDate.toDateString()) {
  		#  	result = { prefix: "Dziś, ", datetime: #{date.strftime('%H:%M ')} }
    #   } else if (newDate.toDateString() == new Date(new Date().setDate(new Date().getDate() +1 )).toDateString()) {
  		# 	result =	{ prefix: "Jutro, ", datetime: #{date.strftime('%H:%M ')} }
  		# } else {
    #     result = { prefix: '', datetime: #{date.strftime('%d')} + ' ' + newDate.toLocaleString('pl-PL', { month: "short" }) + ' ' + #{date.strftime('%Y %H:%M ')} }
  		# }`
  		# Native(`result`)
    # else
    # end
    if date.present? && date.loaded?
      newDate = Time.parse(date)
      result = nil
      if newDate.strftime('%d.%m.%Y') == (Time.now - 1.days).strftime('%d.%m.%Y')
        result = { prefix: "Wczoraj, ", datetime: newDate.strftime('%H:%M ') }
      elsif newDate.strftime('%d.%m.%Y') == (Time.now).strftime('%d.%m.%Y')
        result = { prefix: "Dziś, ", datetime: newDate.strftime('%H:%M ') }
      elsif newDate.strftime('%d.%m.%Y') == (Time.now + 1.days).strftime('%d.%m.%Y')
        result = { prefix: "Jutro, ", datetime: newDate.strftime('%H:%M ') }
      else
        months = ['', 'sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru']
        result = { prefix: '', datetime: "#{newDate.strftime('%d')} #{months[newDate.month]} #{newDate.strftime('%Y %H:%M ')}" }
      end
      result
    end
  end

  def set_formatted_date(date = params.trip.arrival_time)
		x = get_formatted_date date
		hash = { prefix: x[:prefix], datetime: x[:datetime] }
		mutate.formatted_date hash
	end

  def render
    div(class: "trip-card-wrapper #{'dark-overlay' if !!params.about_to_remove}") do

      div() do
        div(class: "remove-wrapper #{'shown' if !!params.about_to_remove }") do
          button(class: "btn icon-only btn-container text-white white-border white-bg remove-btn", type: "button") do
            i(class: 'ero-trash f-s-22 text-secondary')
          end.on :click do |e|
            confirm_deletion params.trip, e
          end
          span(class: "text-white f-s-18") {'Usuń przejazd'}
        end

        div(class: "trip-mobile-photo-container") do
          div(class: 'trip-img') do
            img(src: params.trip.try(:avatar_url) || '/assets/group-blank.png')
          end
        end

        div(class: "trip-card" ) do

          # 1st element
          div(class: 'trip-img') do
            img(src: params.trip.try(:avatar_url) || '/assets/group-blank.png')
          end

          # 2nd element
          div(class: 'trip-text') do

            div() do
              h4(class: "trip-title trip-user-#{params.trip.try(:user).try(:id)}") do
                if CurrentUserStore.current_user && CurrentUserStore.current_user.try(:lon) && CurrentUserStore.current_user.try(:lat) && params.trip.present? && params.trip.through(CurrentUserStore.current_user.lon, CurrentUserStore.current_user.lat)
                  span { get_formatted_date(params.trip.try(:arrival_time)).try(:[], 'prefix') || '' }
                  span { "zapytaj o godzinę " }.on(:click) do
                    open_messenger(params.trip)
                  end
                else
                  span { get_formatted_date(params.trip.try(:arrival_time)).try(:[], "prefix") || '' }
                  span { get_formatted_date(params.trip.try(:arrival_time)).try(:[], "datetime") || '' }
                end

                span(class: "#{'text-secondary-light' unless has_inter_destinations? && get_destinations.present?}") { get_main_destinations }

                if has_inter_destinations? && get_destinations.present?
                  span(style: { whiteSpace: 'nowrap' }) do
                    span { " przez" }
                    span(class: 'text-secondary-light') { " #{get_destinations}" }
                  end
								end
								# span(style: { whiteSpace: 'nowrap' }) do
								# 	span { " przez" }
								# 	if params.trip.present? && params.trip['destinations'].present? && params.trip['destinations']['data'].present? && params.trip['destinations']['data'][0].present? && params.trip['destinations']['data'][0]['city'].present?
								# 		span(class: 'text-secondary-light') { " #{params.trip['destinations']['data'][0]['city']}" }
								# 	end
								# 	if has_inter_destinations? && get_destinations.present?
								# 		span(class: 'text-secondary-light') { ", #{get_destinations}" }
								# 	end
								# end if params.trip.present? && params.trip.destinations.present? && params.trip.destinations.loaded?
              end

              p(class: 'text-book text-gray trip-text-content') { params.trip.try(:description) }
            end

            UserDescriptor( user: params.trip.try(:user), show_status: true, show_verification: true, show_two_lined: false)
          end

          if CurrentUserStore.current_user_id != params.trip.try(:user_id)
            button(class: 'btn icon-only btn-container text-white white-border secondary-bg btn-top', type: "button") do
              i(class: 'ero-messages f-s-18')
            end.on :click do
              open_messenger params.trip
            end
          else
            button(class: 'btn icon-only btn-container text-white white-border secondary-bg btn-top', type: "button") do
              i(class: 'ero-pencil f-s-18')
            end.on :click do |e|
              edit_trip params.trip, e
            end

            button(class: 'btn icon-only btn-container text-gray white-border lightest-gray-bg btn-warning btn-bottom', type: "button") do
              i(class: 'ero-trash')
            end.on(:click) { |e| remove_trip params.trip, e }
          end
        end.on(:click) do |e|
          go_to_profile(params.trip, e)
        end

      end
    end
    # .while_loading do
    #   mocked_trip
    # end
  end

  def has_inter_destinations?
    # params.trip.try(:destinations).try(:[], 'data').try(:size).try(:>, 2)
    true
  end

  def get_destinations
    a = params.trip.try(:destinations).try(:[], 'data')
    return unless a.is_a? Array
    closest = Hash["city", nil, "distance", nil]
    closest[:city] = ''
    closest[:distance] = nil

    a[0..(a.count - 1)].each do |location|
      rad_per_deg = Math::PI / 180
      rm = 6371000
      lat1 = location[:lat]
      lon1 = location[:lon]
      lat2 = CurrentUserStore.current_user.try(:lat).try(:loaded?) ? CurrentUserStore.current_user.try(:lat) : nil
      lon2 = CurrentUserStore.current_user.try(:lon).try(:loaded?) ? CurrentUserStore.current_user.try(:lon) : nil
      unless lat2.blank? || lon2.blank? || lat1.nil? || lon1.nil?
        lat1_rad = lat1.to_i * rad_per_deg
        lat2_rad = lat2.to_i * rad_per_deg
        lon1_rad = lon1.to_i * rad_per_deg
        lon2_rad = lon2.to_i * rad_per_deg
        # puts "lat1_rad: #{lat1_rad} - #{lat1_rad.class.to_s}, lat2_rad: #{lat2_rad} - #{lat2_rad.class.to_s}, lon1_rad: #{lon1_rad} - #{lon1_rad.class.to_s}, lon2_rad: #{lon2_rad} - #{lon2_rad.class.to_s}"
        # puts 'before halo koalo'
        x = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
        # puts "after 1 #{x}, #{x.class.to_s}"
        c = 2 * Math::atan2(Math::sqrt(x), Math::sqrt(1 - x))
        # puts "after 2 #{c}, #{c.class.to_s}"
        distance = rm * c # meters
        if (closest[:city].nil? || closest[:distance].nil? || closest[:distance] > distance)
            closest[:city] = location[:city]
            closest[:distance] = distance
         end
        end
      end
    return closest[:city] = params.trip.destinations.try(:[], 'data').last["city"] == closest[:city] ? nil : closest[:city]
  end


  def get_main_destinations
    if params.trip.try(:destinations).try(:[], 'data').present?
      a = params.trip.try(:destinations).try(:[], 'data').try(:[], -1)
      a['city'] unless a.is_a? Integer
    else
      ''
    end
  end

  def edit_trip trip, event
    event.prevent_default
    event.stop_propagation
    if CurrentUserStore.current_user.blank?
      ModalsService.open_modal('RegistrationModal', { callback: proc { do_edit_trip(trip) } })
    else
      do_edit_trip(trip)
    end
  end

  def do_edit_trip trip
    ModalsService.open_modal('EditTripModal', {size_class: 'modal-lg', trip_id: trip.try(:id)})
  end

  def remove_trip trip, event=nil
    if event
      event.prevent_default
      event.stop_propagation
    end
    params.on_remove_init.call(trip.try(:id))
  end

  def confirm_deletion trip, event=nil
    if event
      event.prevent_default
      event.stop_propagation
    end
    RemoveTrip.run(id: trip.try(:id)).then do |data|
      `toast.dismiss(); toast.success('Usunęliśmy przejazd.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
    end.fail do |err|
      `toast.dismiss(); toast.error('Nie udało się usunąć przejazdu.')`
    end
  end

  def go_to_profile trip, event=nil
    if event
      event.prevent_default
      event.stop_propagation
    end
    if trip.try(:user_id) != CurrentUserStore.current_user_id
      if !trip.try(:is_anonymous) && trip.try(:user).present? && !trip.try(:user).try(:is_private)
        AppRouter.push("/profile/#{trip.user_id}?trip=#{trip.try(:id)}")
      else
        if CurrentUserStore.current_user.present?
          open_messenger trip
        else
          ModalsService.open_modal('RegistrationModal', { callback: proc { go_to_profile(params.trip) } })
        end
      end
    end
  end

  def open_messenger trip, message = "Hej, chętnie Cię poznam ;)"
    puts "open_messenger #{trip.try(:user).try(:id)} #{CurrentUserStore.current_user_id}"
    if trip.try(:user).try(:id) != CurrentUserStore.current_user_id
      mutate.blocking true
      GetRoomUserForContextAndJoin.run({ context_type: 'Trip', context_id: trip.id })
      .then do |room_user|
        puts "room_user #{room_user}"
        mutate.blocking false
        # `console.log('we have room_user', room_user.context_id, room_user.id, room_user)`
        ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static', initial_room_user_id: room_user.try(:id), initial_message: message })
      end.catch do |e|
        mutate.blocking false
        puts "ERROR, #{e.inspect}"
      end
    end
  end

end