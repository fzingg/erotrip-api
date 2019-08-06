class MessengerSubheaderForHotline < Hyperloop::Component

  param :active_room_user
  param :close
  param :activate_room_user

  state rolled_down: false

  def opposite_not_permitted
    result = true
    permission = AccessPermission.profile_granted.where_owner(params.active_room_user.dependent_resource_owner_id).where_permitted((params.active_room_user.room_user_ids - [params.active_room_user.dependent_resource_owner_id]).first)
    result = false if permission.try(:loaded?) && permission.count > 0

    if !!result
      permission = HotlineAccessPermission.ransacked({
        is_permitted: true,
        hotline_id_eq: params.active_room_user.room_hotline_id,
        owner_id_eq: params.active_room_user.dependent_resource_owner_id,
        permitted_id: (params.active_room_user.room_user_ids - [params.active_room_user.dependent_resource_owner_id]).first
      })

      result = false if permission.try(:loaded?) && permission.count > 0
    end
    result
  end

  def render

    hotline = Hotline.find(params.active_room_user.room_hotline_id)

    div(class: "messenger-header messenger-header-hotline-secondary #{ 'rolled-down' if state.rolled_down }") do
      div(class: 'g-wrapper') do

        # IMAGE
        div(class: 'g-image-wrapper') do
          img(src: hotline.try(:avatar_url) ? hotline.try(:avatar_url) + (opposite_not_permitted ? '0' : '1') : '/assets/user-blank.png')
          if (hotline.try(:is_anonymous) || hotline.try(:user).try(:is_private)) && opposite_not_permitted
            div(class: 'g-image-locker') do
              i(class: 'ero-locker')
            end
          end
        end

        # DESCRIPTION
        div(class: 'g-description-wrapper') do

          div(class: 'g-header') do
            div(class: 'messenger-hotline-date') do
              # UserDescriptor(
              #   user: hotline.try(:user),
              #   show_status: true,
              #   show_verification: false,
              #   show_two_lined: false,
              #   show_city: false
              # )
              hotline.try(:city)
            end
          end

          div(class: 'g-description') { hotline.try(:content) }
          div(class: 'messenger-hotline-info-lower') { hotline.try(:created_at).present? ? get_created_at_humanized(hotline.try(:created_at)) : '' }
          # div(class: 'g-description') { "Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text Bardzo długi text" }

          # button(class: 'btn btn-secondary btn-unlock', type: 'button') do
          #   span {'Pokaż się'}
          # end
        end
      end
      # if (hotline.try(:is_anonymous) || hotline.try(:user).try(:is_private)) && params.active_room_user.room_owner_id == CurrentUserStore.current_user_id
      #   button(class: 'button btn btn-secondary', type: 'button') do
      #     'Odblokuj'
      #   end.on :click do
      #     unlock_hotline
      #   end
      # end

      # SHOW BUTTON
      button(class: "btn btn-show-hotline") do
        i(class: 'ero-arrow-left')
      end.on :click do
        mutate.rolled_down !state.rolled_down
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