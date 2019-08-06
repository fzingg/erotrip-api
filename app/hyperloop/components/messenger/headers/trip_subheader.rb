class MessengerSubheaderForTrip < Hyperloop::Component

  param :active_room_user
  param :close
  param :activate_room_user

  state rolled_down: false

  def opposite_not_permitted
    result = true
    permission = AccessPermission.profile_granted.where_owner(params.active_room_user.dependent_resource_owner_id).where_permitted((params.active_room_user.room_user_ids - [params.active_room_user.dependent_resource_owner_id]).first)
    result = false if permission.try(:loaded?) && permission.count > 0

    if !!result
      permission = TripAccessPermission.ransacked({
        is_permitted: true,
        trip_id_eq: params.active_room_user.room_trip_id,
        owner_id_eq: params.active_room_user.dependent_resource_owner_id,
        permitted_id: (params.active_room_user.room_user_ids - [params.active_room_user.dependent_resource_owner_id]).first
      })

      result = false if permission.try(:loaded?) && permission.count > 0
    end
    result
  end

  def render

    trip = Trip.find(params.active_room_user.room_trip_id)

    div(class: "messenger-header messenger-header-trip-secondary #{ 'rolled-down' if state.rolled_down }") do
      div(class: 'g-wrapper') do

        # IMAGE
        div(class: 'g-image-wrapper') do
          img(src: trip.try(:avatar_url) ? trip.try(:avatar_url) + (opposite_not_permitted ? '0' : '1') : '/assets/user-blank.png')
          if (trip.try(:is_anonymous) || trip.try(:user).try(:is_private)) && opposite_not_permitted
            div(class: 'g-image-locker') do
              i(class: 'ero-locker')
            end
          end
        end

        # DESCRIPTION
        div(class: 'g-description-wrapper') do

          div(class: 'g-header') do
            div(class: 'messenger-trip-date') do
              # UserDescriptor(
              #   user: trip.try(:user),
              #   show_status: true,
              #   show_verification: false,
              #   show_two_lined: false,
              #   show_city: false
              # )
              span(class: "#{'text-secondary-light' unless has_inter_destinations? && get_destinations(trip).present?}") { get_main_destinations(trip) }

              if has_inter_destinations? && get_destinations(trip).present?
                span(style: { whiteSpace: 'nowrap' }) do
                  span { " przez" }
                  span(class: 'text-secondary-light') { " #{get_destinations(trip)}" }
                end
              end
            end
          end

          div(class: 'g-description') { trip.try(:description) }
          div(class: 'messenger-trip-info-lower') do
            if CurrentUserStore.current_user.try(:lon).try(:loaded?) && CurrentUserStore.current_user.try(:lat).try(:loaded?) && trip.try(:loaded?) && trip.through(CurrentUserStore.current_user.lon, CurrentUserStore.current_user.lat)
              span { get_formatted_date(trip.try(:arrival_time)).try(:[], 'prefix') || '' }
              span { "zapytaj o godzinę " }
              # .on(:click) do
              #   open_messenger(trip)
              # end
            else
              span { get_formatted_date(trip.try(:arrival_time)).try(:[], "prefix") || '' }
              span { get_formatted_date(trip.try(:arrival_time)).try(:[], "datetime") || '' }
            end
          end
          # div(class: 'g-description') { "Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text" }

          # button(class: 'btn btn-secondary btn-unlock', type: 'button') do
          #   span {'Pokaż się'}
          # end
        end
      end
      # if (trip.try(:is_anonymous) || trip.try(:user).try(:is_private)) && params.active_room_user.room_owner_id == CurrentUserStore.current_user_id
      #   button(class: 'button btn btn-secondary', type: 'button') do
      #     'Odblokuj'
      #   end.on :click do
      #     unlock_trip
      #   end
      # end

      # SHOW BUTTON
      button(class: "btn btn-show-trip") do
        i(class: 'ero-arrow-left')
      end.on :click do
        mutate.rolled_down !state.rolled_down
      end
    end

  end

  def get_formatted_date(date)
    if date.present? && date.loaded?
      new_date = Time.parse(date)
      result = nil
      if new_date.strftime('%d.%m.%Y') == (Time.now - 1.days).strftime('%d.%m.%Y')
        result = { prefix: "Wczoraj, ", datetime: new_date.strftime('%H:%M ') }
      elsif new_date.strftime('%d.%m.%Y') == (Time.now).strftime('%d.%m.%Y')
        result = { prefix: "Dziś, ", datetime: new_date.strftime('%H:%M ') }
      elsif new_date.strftime('%d.%m.%Y') == (Time.now + 1.days).strftime('%d.%m.%Y')
        result = { prefix: "Jutro, ", datetime: new_date.strftime('%H:%M ') }
      else
        months = ['', 'sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru']
        result = { prefix: '', datetime: "#{new_date.strftime('%d')} #{months[new_date.month]} #{new_date.strftime('%Y %H:%M ')}" }
      end
      result
    else
      result = ''
    end
    result
  end

  def has_inter_destinations?
    # trip.try(:destinations).try(:[], 'data').try(:size).try(:>, 2)
    true
  end

  def get_destinations(trip)
    a = trip.try(:destinations).try(:[], 'data')
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
    return closest[:city] = trip.destinations.try(:[], 'data').last["city"] == closest[:city] ? nil : closest[:city]
  end


  def get_main_destinations(trip)
    if trip.try(:destinations).try(:[], 'data').present?
      a = trip.try(:destinations).try(:[], 'data').try(:[], -1)
      a['city'] unless a.is_a? Integer
    else
      ''
    end
  end

end