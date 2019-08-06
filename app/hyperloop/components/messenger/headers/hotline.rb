class MessengerHeaderForHotline < Hyperloop::Component

  param :active_room_user
  param :close
  param :activate_room_user

  def render

    hotline = Hotline.find(params.active_room_user.room_hotline_id)

    div(class: "messenger-header messenger-header-hotline-primary") do

      # close button
      button(class: 'btn btn-messenger-back d-md-none') do
        i(class: 'ero-arrow-left')
      end.on :click do
        params.activate_room_user.call nil
      end

      div(class: 'g-wrapper') do
        div(class: "messenger-hotline-counter #{'unread' if (params.active_room_user.unread_counter || 0) > 0}") do
          if (params.active_room_user.unread_counter || 0) > 0
            div(class: 'mt-1') { "+#{params.active_room_user.unread_counter}" }
          else
            div(class: 'mt-1') { (params.active_room_user.room_user_ids.length - 1 || 0).to_s }
          end
        end

        div(class: 'messenger-hotline-info') do
          div(class: 'messenger-hotline-info-upper') { 'Hotline' }
          div(class: 'messenger-hotline-info-lower') { hotline.try(:created_at).present? ? get_created_at_humanized(hotline.try(:created_at)) : '' }
        end

        # messnger header button
        div(class: 'messenger-hotline-header-button') do
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

  def get_created_at_humanized(date)
    if date.present?
      new_date = Time.parse(date.to_s)
      result = nil
      if new_date.strftime('%d.%m.%Y') == (Time.now - 1.days).strftime('%d.%m.%Y')
        result = "Wczoraj, #{new_date.strftime('%H:%M')}"
      elsif new_date.strftime('%d.%m.%Y') == (Time.now).strftime('%d.%m.%Y')
        minutes_ago = ((Time.now.to_i - new_date.to_i) / 60).to_i.abs
        if minutes_ago < 60
          result = "#{minutes_ago} min temu"
        else
          result = "Dziś, #{new_date.strftime('%H:%M')}"
        end

      elsif new_date.strftime('%d.%m.%Y') == (Time.now + 1.days).strftime('%d.%m.%Y')
        result = "Jutro, #{new_date.strftime('%H:%M ')}"
      else
        months = ['', 'sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru']
        result = "#{new_date.strftime('%d')} #{months[new_date.month]} #{new_date.strftime('%Y %H:%M ')}"
      end
    else
      result = ''
    end
    result
  end

end