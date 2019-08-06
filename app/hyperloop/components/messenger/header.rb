class MessengerHeader < Hyperloop::Component
  param :active_room_user
  param :close
  param :activate_room_user
  param is_permitted: nil, nils: true

  state rolled_down: false;

  def unlock_hotline
    `alert('w trakcie implementacji')`
  end

  def alert_user user
    ModalsService.open_modal('UserAlert', { size_class: 'modal-md', resource_id: user.try(:id), resource_type: 'User' })
  end

  def get_created_at_humanized(date)
    new_date = Time.parse(date)
    result = nil
    if new_date.strftime('%d.%m.%Y') == (Time.now - 1.days).strftime('%d.%m.%Y')
      result = { prefix: "Wczoraj, ", datetime: new_date.strftime('%H:%M ') }
    elsif new_date.strftime('%d.%m.%Y') == (Time.now).strftime('%d.%m.%Y')
      minutes_ago = ((Time.now.to_i - new_date.to_i) / 60).to_i.abs
      if minutes_ago < 60
        result = { prefix: "", datetime: "#{minutes_ago} min temu" }
      else
        result = { prefix: "Dziś, ", datetime: new_date.strftime('%H:%M ') }
      end

    elsif new_date.strftime('%d.%m.%Y') == (Time.now + 1.days).strftime('%d.%m.%Y')
      result = { prefix: "Jutro, ", datetime: new_date.strftime('%H:%M ') }
    else
      months = ['', 'sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru']
      result = { prefix: '', datetime: "#{new_date.strftime('%d')} #{months[new_date.month]} #{new_date.strftime('%Y %H:%M ')}" }
    end
    result
  end

  def am_i_anonymous
    result = false
    if params.active_room_user.present? && params.active_room_user.try(:loaded?)

      me = CurrentUserStore.current_user
      me_id = CurrentUserStore.current_user_id

      other_user_id = (params.active_room_user.room_user_ids - [me_id]).first

      if params.active_room_user.room_trip_id.blank? && params.active_room_user.room_hotline_id.blank?

        result = CurrentUserStore.current_user.try(:is_private)

        if !!result
          permission = AccessPermission.profile_granted.where_owner(me_id).where_permitted(other_user_id)
          result = false if permission.try(:loaded?) && permission.count > 0
        end

      elsif params.active_room_user.room_trip_id.present?


        if params.active_room_user.dependent_resource_owner_id == me_id
          result = params.active_room_user.is_trip_anonymous || me.try(:is_private)
        else
          result = me.try(:is_private)
        end

        if !!result
          permission = AccessPermission.profile_granted.where_owner(me_id).where_permitted(other_user_id).first
          result = false if permission.try(:loaded?) && permission.present?
        end

        if !!result
          permission = TripAccessPermission.ransacked({
            is_permitted: true,
            trip_id_eq: params.active_room_user.room_trip_id,
            owner_id_eq: me_id,
            permitted_id_eq: other_user_id
          })
          result = false if permission.try(:loaded?) && permission.count > 0
        end

      elsif params.active_room_user.room_hotline_id.present?


        if params.active_room_user.dependent_resource_owner_id == me_id
          result = params.active_room_user.is_hotline_anonymous || me.try(:is_private)
        else
          result = me.try(:is_private)
        end

        if !!result
          permission = AccessPermission.profile_granted.where_owner(me_id).where_permitted(other_user_id)
          result = false if permission.try(:loaded?) && permission.count > 0
        end

        if !!result
          permission = HotlineAccessPermission.ransacked({
            is_permitted: true,
            hotline_id_eq: params.active_room_user.room_hotline_id,
            owner_id_eq: me_id,
            permitted_id_eq: other_user_id
          })
          result = false if permission.try(:loaded?) && permission.count > 0
        end

      end
    end
    result
  end

  def render
    div() do
      am_i_anonymous

      # MAIN HEADER
      if params.active_room_user.present? && !params.active_room_user.try(:is_trip_grouped?) && !params.active_room_user.try(:is_hot_grouped?)

        MessengerHeaderForUser(active_room_user: params.active_room_user, close: params.close, activate_room_user: params.activate_room_user, is_permitted: params.is_permitted)

      elsif params.active_room_user.present? && params.active_room_user.try(:is_hot_grouped?)

        MessengerHeaderForHotline(active_room_user: params.active_room_user, close: params.close, activate_room_user: params.activate_room_user)

      elsif params.active_room_user.present? && params.active_room_user.try(:is_trip_grouped?)

        MessengerHeaderForTrip(active_room_user: params.active_room_user, close: params.close, activate_room_user: params.activate_room_user)

      end
      # END: MAIN HEADER


      if params.active_room_user.present? && !owner_of_grouped_room && am_i_anonymous

        MessengerSubheaderForAnonymousUser(active_room_user: params.active_room_user, unlock_for_opposite: proc { unlock_for_opposite } )

      end

      # SUBHEADER
      if params.active_room_user.present? && params.active_room_user.room_hotline_id.present?

        MessengerSubheaderForHotline(active_room_user: params.active_room_user, close: params.close, activate_room_user: params.activate_room_user)

      elsif params.active_room_user.present? && params.active_room_user.room_trip_id.present?

        MessengerSubheaderForTrip(active_room_user: params.active_room_user, close: params.close, activate_room_user: params.activate_room_user)

      end
      # END: SUBHEADER

    end
  end

  def owner_of_grouped_room
    (params.active_room_user.try(:is_trip_grouped?) || params.active_room_user.try(:is_hot_grouped?)) && params.active_room_user.try(:dependent_resource_owner_id) == CurrentUserStore.current_user_id
  end


  def unlock_for_opposite
    if params.active_room_user.room_hotline_id.present?
      SaveHotlineAccessPermission.run({ hotline_id: params.active_room_user.room_hotline_id, owner_id: CurrentUserStore.current_user_id, permitted_id: (params.active_room_user.room_user_ids - [CurrentUserStore.current_user_id]).first, is_permitted: true }).catch do |err|
        `toast.error('Nie udało się pokazać.')`
      end
    elsif params.active_room_user.room_trip_id.present?
      SaveTripAccessPermission.run({ trip_id: params.active_room_user.room_trip_id, owner_id: CurrentUserStore.current_user_id, permitted_id: (params.active_room_user.room_user_ids - [CurrentUserStore.current_user_id]).first, is_permitted: true }).catch do |err|
        `toast.error('Nie udało się pokazać.')`
      end
    else
      SaveAccessPermission.run({ owner_id: CurrentUserStore.current_user_id, permitted_id: (params.active_room_user.room_user_ids - [CurrentUserStore.current_user_id]).first, profile_granted: true, profile_requested: true }).catch do |err|
        `toast.error('Nie udało się pokazać.')`
      end
    end
  end

end












# class MessengerHeader < Hyperloop::Component
#   param :active_room
#   param :close

#   state rolled_down: false;

#   def unlock_hotline
#     `alert('w trakcie implementacji')`
#   end

#   def alert_user user
#     ModalsService.open_modal('UserAlert', { size_class: 'modal-md', resource_id: user.try(:id), resource_type: 'User' })
#   end

#   def render
#     div() do
#       if params.active_room.present? && (params.active_room.room_id.present? || (params.active_room.hotline.blank? && params.active_room.trip.blank?))
#         # instead of entire Hyperloop::Model... we should do sth like below
#         # tried approach:
#         user = RoomUser.ransacked({user_id_not_eq: CurrentUserStore.current_user_id, room_id_eq: params.active_room.id}).first
#         # it doesn't work and dunno why :(
#         # Hyperloop::Model.load do
#         #   params.active_room.room_users
#         # end.then do |room_users|
#         #   if room_users.respond_to?(:each)
#         #     user = params.active_room.room_users.select{ |ru| ru.try(:user_id) != CurrentUserStore.current_user_id }.try(:first).try(:user)
#         #   else
#         #     user = nil
#         #   end

#         div(class: 'messenger-header') do

#           # close button
#           button(class: 'btn btn-messenger-back d-md-none') do
#             i(class: 'ero-arrow-left')
#           end.on :click do
#             mutate.active_room nil
#           end

#           div(class: 'g-wrapper') do
#             if user.try(:user).try(:is_verified)
#               div(class: 'messenger-verified-circle') do
#                 i(class: 'ero-checkmark')
#               end
#             else
#               div(class: 'messenger-not-verified')
#             end

#             div(class: 'messenger-profile-info') do
#               div(class: 'messenger-profile-info-upper') do
#                 UserDescriptor(
#                   user: user.try(:user),
#                   show_status: true,
#                   show_verification: false,
#                   show_two_lined: false,
#                   show_city: false
#                 )
#               end
#               div(class: 'messenger-profile-info-lower') do
#                 span { user.try(:user).try(:last_active_at_humanized).present? ? "#{user.try(:user).try(:last_active_at_humanized)}, " : '' }
#                 span { (user.try(:user).try(:city) || '') }
#               end
#             end

#             # messnger header button
#             div(class: 'messenger-header-button') do
#               button(class: 'btn btn-header-button', type:'button') do
#                 span {"..."}

#                 div(class: "header-dropdown-menu") do
#                   div(class: "header-dropdown-option") do
#                     i(class: "ero-trash")
#                     span() { 'Usuń konwersację' }
#                   end
#                   div(class: "header-dropdown-option") do
#                     i(class: "ero-search")
#                     span() { 'Inna akcja' }
#                   end
#                   div(class: "header-dropdown-option") do
#                     i(class: "ero-checkmark")
#                     span() { 'Inna akcja' }
#                   end
#                 end
#               end.on :click do |e|
#                 e.prevent_default
#                 e.stop_propagation
#               end
#             end
#           end

#         end.on :click do
#           AppRouter.push "/profile/#{user.try(:id)}"
#           params.close.call
#         end
#       end
#       # END: HEADER FOR USER IF IT'S NOT HOTLINE/TRIP DIRECT ROOM


#       # HEADER FOR HOTLINE
#       if params.active_room.present? && params.active_room.hotline_id.present? && params.active_room.owner_id != CurrentUserStore.current_user_id
#         div(class: "messenger-header messenger-header-hotline-secondary #{ 'rolled-down' if state.rolled_down }") do
#           div(class: 'g-wrapper') do

#             # IMAGE
#             div(class: 'g-image-wrapper') do
#               img(src: (params.active_room.hotline.try(:is_anonymous) || params.active_room.hotline.try(:user).try(:is_private) ? params.active_room.hotline.try(:user).try(:blurred_avatar_url) : params.active_room.hotline.try(:user).try(:avatar_url)) || '/assets/user-blank.png')
#               # if params.active_room.hotline.try(:is_anonymous)
#               if true
#                 div(class: 'g-image-locker') do
#                   i(class: 'ero-locker')
#                 end
#               end
#             end

#             # DESCRIPTION
#             div(class: 'g-description-wrapper') do

#               div(class: 'g-header') do
#                 # span(class: 'messnger-hotline-date') { state.created_at_humanized.present? ? "#{state.created_at_humanized['prefix']}#{state.created_at_humanized['datetime']}" : '' }
#                 span(class: 'messnger-hotline-date') { '17.12.2017' }

#                 # span(class: 'messnger-hotline-city') { params.active_room.try(:hotline).try(:city) }
#                 span(class: 'messnger-hotline-city') { 'Łódź' }
#               end

#               # div(class: 'g-description') { params.active_room.hotline.try(:content) }
#               div(class: 'g-description') { "Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text" }
#             end
#           end
#           if (params.active_room.hotline.try(:is_anonymous) || params.active_room.hotline.try(:user).try(:is_private)) && CurrentUserStore.current_user_id == params.active_room.hotline.try(:user).try(:id)
#             button(class: 'button btn btn-secondary', type: 'button') do
#               'Odblokuj'
#             end.on :click do
#               unlock_hotline
#             end
#           end

#           # SHOW BUTTON
#           button(class: "btn btn-show-hotline") do
#             i(class: 'ero-arrow-left')
#           end.on :click do
#             mutate.rolled_down !state.rolled_down
#           end
#         end
#       end
#       # END: HEADER FOR HOTLINE

#       # HEADER FOR HOTLINE WHEN OWNER
#       if params.active_room.present? && params.active_room.hotline_id.present? && params.active_room.owner_id == CurrentUserStore.current_user_id
#         div(class: "messenger-header messenger-header-hotline-primary") do

#           # close button
#           button(class: 'btn btn-messenger-back d-md-none') do
#             i(class: 'ero-arrow-left')
#           end.on :click do
#             mutate.active_room nil
#           end

#           div(class: 'g-wrapper') do
#             div(class: 'messenger-hotline-counter') do
#               div(class: 'mt-1') {'3'}
#             end

#             div(class: 'messenger-hotline-info') do
#               div(class: 'messenger-hotline-info-upper') {'17 gru 2017'}
#               div(class: 'messenger-hotline-info-lower') {'Łódź'}
#             end

#             # messnger header button
#             div(class: 'messenger-hotline-header-button') do
#               button(class: 'btn btn-delete-button', type:'button') do
#                 i(class: 'ero-trash')
#               end.on :click do |e|
#                 e.prevent_default
#                 e.stop_propagation
#               end
#             end
#           end
#         end

#         div(class: "messenger-header messenger-header-hotline-secondary #{ 'rolled-down' if state.rolled_down }") do
#           div(class: 'g-wrapper') do

#             # IMAGE
#             div(class: 'g-image-wrapper') do
#               img(src: (params.active_room.hotline.try(:is_anonymous) || params.active_room.hotline.try(:user).try(:is_private) ? params.active_room.hotline.try(:user).try(:blurred_avatar_url) : params.active_room.hotline.try(:user).try(:avatar_url)) || '/assets/user-blank.png')
#               # if params.active_room.hotline.try(:is_anonymous)
#               if true
#                 div(class: 'g-image-locker') do
#                   i(class: 'ero-locker')
#                 end
#               end
#             end

#             # DESCRIPTION
#             div(class: 'g-description-wrapper') do

#               div(class: 'g-header') do
#                 span(class: 'messnger-hotline-date') { 'Test' }
#               end

#               # div(class: 'g-description') { params.active_room.hotline.try(:content) }
#               div(class: 'g-description') { "Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text" }

#               button(class: 'btn btn-secondary btn-unlock', type: 'button') do
#                 span {'Pokaż się'}
#               end
#             end
#           end
#           if (params.active_room.hotline.try(:is_anonymous) || params.active_room.hotline.try(:user).try(:is_private)) && CurrentUserStore.current_user_id == params.active_room.hotline.try(:user).try(:id)
#             button(class: 'button btn btn-secondary', type: 'button') do
#               'Odblokuj'
#             end.on :click do
#               unlock_hotline
#             end
#           end

#           # SHOW BUTTON
#           button(class: "btn btn-show-hotline") do
#             i(class: 'ero-arrow-left')
#           end.on :click do
#             mutate.rolled_down !state.rolled_down
#           end
#         end
#       end
#       # END: HEADER FOR HOTLINE WHEN OWNER



#       # HEADER FOR TRIP
#       if params.active_room.present? && params.active_room.trip_id.present? && params.active_room.owner_id != CurrentUserStore.current_user_id

#         div(class: "messenger-header messenger-header-trip-secondary #{ 'rolled-down' if state.rolled_down }") do
#           div(class: 'g-wrapper') do

#             # IMAGE
#             div(class: 'g-image-wrapper') do
#               img(src: (params.active_room.trip.try(:is_anonymous) || params.active_room.trip.try(:user).try(:is_private) ? params.active_room.trip.try(:user).try(:blurred_avatar_url) : params.active_room.trip.try(:user).try(:avatar_url)) || '/assets/user-blank.png')
#               # if params.active_room.trip.try(:is_anonymous)
#               if true
#                 div(class: 'g-image-locker') do
#                   i(class: 'ero-locker')
#                 end
#               end
#             end

#             # DESCRIPTION
#             div(class: 'g-description-wrapper') do

#               div(class: 'g-header') do
#                 span(class: 'messnger-hotline-date') { 'Test' }
#               end
#               # div(class: 'g-header') do
#               #   span(class: 'messnger-trip-date') do
#               #     span { params.active_room.try(:trip).try(:formatted_date)["prefix"] }
#               #     span { params.active_room.try(:trip).try(:formatted_date)["datetime"] }
#               #   end

#               #   span(class: 'messnger-trip-city') do
#               #     span(class: "#{'text-secondary-light' unless has_inter_destinations? && get_destinations.present?}") { get_main_destinations }

#               #     if has_inter_destinations? && get_destinations.present?
#               #       span(style: { whiteSpace: 'nowrap' }) do
#               #         span { " przez" }
#               #         span(class: 'text-secondary-light') { " #{get_destinations}" }
#               #       end
#               #     end
#               #   end
#               # end

#               div(class: 'g-description') { params.active_room.try(:trip).try(:description) }
#             end
#           end
#           if (params.active_room.trip.try(:is_anonymous) || params.active_room.trip.try(:user).try(:is_private)) && CurrentUserStore.current_user_id == params.active_room.trip.try(:user).try(:id)
#             button(class: 'button btn btn-secondary', type: 'button') do
#               'Odblokuj'
#             end.on :click do

#             end
#           end

#           # SHOW BUTTON
#           button(class: "btn btn-show-trip") do
#             i(class: 'ero-arrow-left')
#           end.on :click do
#             mutate.rolled_down !state.rolled_down
#           end
#         end
#       end
#       # END: HEADER FOR TRIP

#       # HEADER FOR TRIP WHEN OWNER
#       if params.active_room.present? && params.active_room.trip_id.present? && params.active_room.owner_id == CurrentUserStore.current_user_id
#         div(class: "messenger-header messenger-header-trip-primary") do

#           # close button
#           button(class: 'btn btn-messenger-back d-md-none') do
#             i(class: 'ero-arrow-left')
#           end.on :click do
#             mutate.active_room nil
#           end

#           div(class: 'g-wrapper') do
#             div(class: 'messenger-trip-counter') do
#               div(class: 'mt-1') {'3'}
#             end

#             div(class: 'messenger-trip-info') do
#               div(class: 'messenger-trip-info-upper') do
#                 span(class: 'mr-1') { params.active_room.try(:trip).try(:formatted_date)["prefix"] }
#                 span { params.active_room.try(:trip).try(:formatted_date)["datetime"] }
#               end

#               div(class: 'messenger-trip-info-lower') do
#                 span(class: "#{'text-secondary-light' unless has_inter_destinations? && get_destinations.present?}") { get_main_destinations }

#                 if has_inter_destinations? && get_destinations.present?
#                   span(style: { whiteSpace: 'nowrap' }) do
#                     span { " przez" }
#                     span(class: 'text-secondary-light') { " #{get_destinations}" }
#                   end
#                 end
#               end
#             end

#             # messnger header button
#             div(class: 'messenger-trip-header-button') do
#               button(class: 'btn btn-delete-button', type:'button') do
#                 i(class: 'ero-trash')
#               end.on :click do |e|
#                 e.prevent_default
#                 e.stop_propagation
#               end
#             end
#           end
#         end

#         div(class: "messenger-header messenger-header-trip-secondary #{ 'rolled-down' if state.rolled_down }") do
#           div(class: 'g-wrapper') do

#             # IMAGE
#             div(class: 'g-image-wrapper') do
#               img(src: (params.active_room.trip.try(:is_anonymous) || params.active_room.trip.try(:user).try(:is_private) ? params.active_room.trip.try(:user).try(:blurred_avatar_url) : params.active_room.trip.try(:user).try(:avatar_url)) || '/assets/user-blank.png')
#               # if params.active_room.trip.try(:is_anonymous)
#               if true
#                 div(class: 'g-image-locker') do
#                   i(class: 'ero-locker')
#                 end
#               end
#             end

#             # DESCRIPTION
#             div(class: 'g-description-wrapper') do

#               div(class: 'g-header') do
#                 span(class: 'messnger-trip-date') do
#                   span { params.active_room.try(:trip).try(:formatted_date)["prefix"] }
#                   span { params.active_room.try(:trip).try(:formatted_date)["datetime"] }
#                 end

#                 span(class: 'messnger-trip-city') do
#                   span(class: "#{'text-secondary-light' unless has_inter_destinations? && get_destinations.present?}") { get_main_destinations }

#                   if has_inter_destinations? && get_destinations.present?
#                     span(style: { whiteSpace: 'nowrap' }) do
#                       span { " przez" }
#                       span(class: 'text-secondary-light') { " #{get_destinations}" }
#                     end
#                   end
#                 end
#               end

#               div(class: 'g-description') { params.active_room.try(:trip).try(:description) }

#               button(class: 'btn btn-secondary btn-unlock', type: 'button') do
#                 span {'Pokaż się'}
#               end
#             end
#           end
#           if (params.active_room.trip.try(:is_anonymous) || params.active_room.trip.try(:user).try(:is_private)) && CurrentUserStore.current_user_id == params.active_room.trip.try(:user).try(:id)
#             button(class: 'button btn btn-secondary', type: 'button') do
#               'Odblokuj'
#             end.on :click do
#               unlock_hotline
#             end
#           end

#           # SHOW BUTTON
#           button(class: "btn btn-show-trip") do
#             i(class: 'ero-arrow-left')
#           end.on :click do
#             mutate.rolled_down !state.rolled_down
#           end
#         end
#       end
#       # END: HEADER FOR TRIP WHEN OWNER

#       div(class: "messenger-header messenger-user-user-anonymous d-none") do
#         div(class: 'g-wrapper') do

#           # IMAGE
#           div(class: 'g-image-wrapper') do
#             img(src: (params.active_room.try(:trip).try(:is_anonymous) || params.active_room.try(:trip).try(:user).try(:is_private) ? params.active_room.try(:trip).try(:user).try(:blurred_avatar_url) : params.active_room.try(:trip).try(:user).try(:avatar_url)) || '/assets/user-blank.png')
#             if true
#               div(class: 'g-image-locker') do
#                 i(class: 'ero-locker')
#               end
#             end
#           end

#           # DESCRIPTION
#           div(class: 'g-description-wrapper') do

#             div(class: 'g-description mr-4 mt-1') do
#               p(class: 'mb-0') { "Aktualnie jesteś anominowy." }
#               p(class: 'mb-0') { "Pokaż się w dowolnym momencie."}
#             end
#           end
#         end

#         button(class: 'btn btn-secondary btn-unlock', type: 'button') do
#           span {'Pokaż się'}
#         end

#       end

#     end
#   end

#   def has_inter_destinations?
#     params.active_room.try(:trip).try(:destinations).try(:[], 'data').try(:size).try(:>, 2)
#   end

#   def get_destinations
#     a = params.active_room.try(:trip).try(:destinations).try(:[], 'data')
#     return unless a.is_a? Array
#     closest = Hash["city", nil, "distance", nil]
#     closest[:city] = ''
#     closest[:distance] = nil

#     a[1..(a.count - 1)].each do |loc|
#       rad_per_deg = Math::PI / 180
#       rm = 6371000
#       lat1 = loc[:lat]
#       lon1 = loc[:lon]
#       lat2 = CurrentUserStore.current_user.try(:lat)
#       lon2 = CurrentUserStore.current_user.try(:lon)
#       unless lat2.nil? || lon2.nil?
#         lat1_rad, lat2_rad = lat1 * rad_per_deg, lat2 * rad_per_deg
#         lon1_rad, lon2_rad = lon1 * rad_per_deg, lon2 * rad_per_deg
#         x = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
#         c = 2 * Math::atan2(Math::sqrt(x), Math::sqrt(1 - x))
#         distance = rm * c # meters
#         if (closest[:city].nil? || closest[:distance].nil? || closest[:distance] > distance)
#           closest[:city] = loc[:city]
#           closest[:distance] = distance
#         end
#       end
#     end
#     return closest[:city] = params.active_room.try(:trip).destinations.try(:[], 'data').last["city"] == closest[:city] ? nil : closest[:city]
#   end

#   def get_main_destinations
#     if params.active_room.try(:trip).try(:destinations).try(:[], 'data').present?
#       a = params.active_room.try(:trip).try(:destinations).try(:[], 'data').try(:[], -1)
#       a['city'] unless a.is_a? Integer
#     else
#       ''
#     end
#   end

# end
