class MessengerSidebarElement < Hyperloop::Component
  param :is_active
  param :room_user
  param :on_click
  param :room_user_updated
  param is_permitted: nil, nils: true
  # state :img_addon

  before_receive_props do |new_props|
    if new_props[:room_user_updated].present? && params.room_user_updated.present? && new_props[:room_user_updated].to_i != params.room_user_updated.to_i
      params.room_user.is_opposite_user_matched!
      params.room_user.can_send_message!
      params.room_user.room_last_message_id!
      params.room_user.room_updated_at!
      params.room_user.opposite_user_avatar_url!
      params.room_user.room_name!
      params.room_user.room_description!

      if new_props[:room_user][:unread_counter].to_i > 0 && (params.is_active == true || new_props[:is_active] == true)
        new_props[:room_user][:unread_counter] = 0
        params.room_user.unread_counter = 0
        ResetRoomUserCounter.run({room_user_id: params.room_user.id})
      end

    elsif params.room_user.unread_counter.to_i > 0 && new_props[:is_active] == true
      new_props[:room_user][:unread_counter] = 0
      params.room_user.unread_counter = 0
      ResetRoomUserCounter.run({room_user_id: params.room_user.id})
    end

    # if params.room_user.present? && new_props[:is_permitted].present? && new_props[:is_permitted] != params.is_permitted
    #   mutate.img_addon Time.now.to_i
    # end
  end

  def room_user
    params.room_user
  end

  def class_part_for room_user
    if room_user.try(:is_hot_grouped?)
      "m-hotline"
    elsif room_user.try(:is_trip_grouped?)
      "m-trip"
    else
      'm-person'
    end
  end

  def render
    if room_user.try(:loaded?)
      div(class: "sidebar-element #{'active' if params.is_active} #{'unread' if (room_user.unread_counter || 0) > 0}") do
        if (room_user.is_trip_grouped? || room_user.is_hot_grouped?) && room_user.dependent_resource_owner_id == CurrentUserStore.current_user_id

          div(class: "sidebar-element-unread-counter #{'has-unread' if (room_user.unread_counter || 0) > 0}") do
            if (room_user.unread_counter || 0) > 0
              div(class: 'mt-1') { "+#{room_user.unread_counter}" }
            else
              div(class: 'mt-1') { (room_user.room_user_ids.length - 1 || 0).to_s }
            end
          end

        else
          div(class: 'sidebar-element-image-wrapper') do
            # img(src: room_user.try(:user_avatar_url) || '/assets/user-blank.png')
            img(src: room_user.try(:opposite_user_avatar_url).present? ? room_user.try(:opposite_user_avatar_url) + (params.is_permitted ? '1' : '0') : '/assets/user-blank.png')
            if room_user.is_opposite_user_matched
              div(class: "sidebar-element-want-to-meet") do
                i(class: 'ero-heart-full')
              end
            end

            if room_user.room_trip_id.present?
              div(class: "sidebar-element-kind-indicator") do
                i(class: 'ero-trips')
              end
            elsif room_user.room_hotline_id.present?
              div(class: "sidebar-element-kind-indicator") do
                i(class: 'ero-hotline')
              end
            end

          end
        end

        div(class: "sidebar-element-details") do
          div(class: "sidebar-element-header") do

            div(class: "sidebar-element-text") { "#{room_user.room_name}" }

            span(class: "m-sidebar-date") {humanized_date(room_user.room_updated_at)}
          end

          div(class: "sidebar-element-description") do
            span(class: "m-last-message-text") { room_user.room_description }
            if (!room_user.is_trip_grouped? && !room_user.is_hot_grouped?) || room_user.dependent_resource_owner_id != CurrentUserStore.current_user_id
              span(class: "sidebar-element-description-status person-status #{room_user.try(:opposite_user_status)}")
            end
          end

        end
      end.on :click do
        params.on_click.call(room_user.room)
      end
    end
  end

  def humanized_date date_obj
    if date_obj.present? && date_obj.loaded?
      date_obj = Time.parse(date_obj.to_s)
      if date_obj.strftime('%d.%m.%Y') == Time.now.strftime('%d.%m.%Y')
        date_obj.strftime('%H:%M')
      elsif date_obj.strftime('%d.%m.%Y') == (Time.now - 1.day).strftime('%d.%m.%Y')
        "wczoraj"
      else
        months = ['', 'sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru']
        "#{date_obj.strftime('%d')} #{months[date_obj.month]}"
      end
    end
  end

end
