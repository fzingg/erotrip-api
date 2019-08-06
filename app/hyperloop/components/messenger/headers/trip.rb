class MessengerHeaderForTrip < Hyperloop::Component

  param :active_room_user
  param :close
  param :activate_room_user

  def render
    trip = Trip.find(params.active_room_user.room_trip_id)

    div(class: "messenger-header messenger-header-trip-primary") do

      # close button
      button(class: 'btn btn-messenger-back d-md-none') do
        i(class: 'ero-arrow-left')
      end.on :click do
        params.activate_room_user.call nil
      end

      div(class: 'g-wrapper') do
        div(class: "messenger-trip-counter #{'unread' if (params.active_room_user.unread_counter || 0) > 0}") do
          if (params.active_room_user.unread_counter || 0) > 0
            div(class: 'mt-1') { "+#{params.active_room_user.unread_counter}" }
          else
            div(class: 'mt-1') { (params.active_room_user.room_user_ids.length - 1 || 0).to_s }
          end
        end

        div(class: 'messenger-trip-info') do
          div(class: 'messenger-trip-info-upper') do
            "Przejazd"

            # span(class: 'mr-1') { trip.try(:formatted_date)["prefix"] }
            # span { trip.try(:formatted_date)["datetime"] }
          end

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
        end

        # messnger header button
        div(class: 'messenger-trip-header-button') do
          button(class: 'btn btn-delete-button', type:'button') do
            i(class: 'ero-trash')
          end.on :click do |e|
            e.prevent_default
            e.stop_propagation
            ArchiveRoomUser.run(room_user_id: params.active_room_user.try(:id))
          end
        end
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