class MessengerHeaderForUser < Hyperloop::Component

  param :active_room_user
  param :close
  param :activate_room_user
  param :is_permitted

  def render
    div(class: 'messenger-header') do

      # close button
      button(class: 'btn btn-messenger-back d-md-none') do
        i(class: 'ero-arrow-left')
      end.on :click do
        params.activate_room_user.call(nil)
        # mutate.active_room nil
      end

      div(class: 'g-wrapper') do
        if params.active_room_user.try(:room).try(:opposite_user).try(:is_verified).try(:loaded?) && params.active_room_user.try(:room).try(:opposite_user).try(:is_verified)
          div(class: 'messenger-verified-circle') do
            i(class: 'ero-checkmark')
          end
        else
          div(class: 'messenger-not-verified')
        end

        div(class: 'messenger-profile-info') do
          div(class: 'messenger-profile-info-upper') do
            UserDescriptor(
              user: params.active_room_user.try(:room).try(:opposite_user),
              show_status: true,
              show_verification: false,
              show_two_lined: false,
              show_city: false
            )
          end
          div(class: 'messenger-profile-info-lower') do
            span { params.active_room_user.try(:room).try(:opposite_user).try(:last_active_at_humanized).present? ? "#{params.active_room_user.try(:room).try(:opposite_user).try(:last_active_at_humanized)}, " : '' }
            span { (params.active_room_user.try(:room).try(:opposite_user).try(:city) || '') }
          end
        end.on :click do
          if params.is_permitted
            AppRouter.push "/profile/#{params.active_room_user.try(:room).try(:opposite_user).try(:id)}?hot=#{params.params.active_room_user.try(:room).try(:hotline_id)}&trip=#{params.active_room_user.try(:room).try(:trip_id)}"
            params.close.call
          else
            `toast.error('Rozmówca jest anonomowy, poproś go o odblokowanie dostępu.')`
          end
        end

        # messnger header button
        div(class: 'messenger-header-button') do
          button(class: 'btn btn-header-button', type:'button') do
            span {"..."}

            div(class: "header-dropdown-menu") do
              div(class: "header-dropdown-option") do
                i(class: "ero-trash")
                span() { 'Usuń konwersację' }
              end.on :click do
                ArchiveRoomUser.run(room_user_id: params.active_room_user.try(:id))
              end
              div(class: "header-dropdown-option") do
                i(class: "ero-search")
                span() { 'Inna akcja' }
              end
              div(class: "header-dropdown-option") do
                i(class: "ero-checkmark")
                span() { 'Inna akcja' }
              end
            end
          end.on :click do |e|
            e.prevent_default
            e.stop_propagation
          end
        end
      end

    end
  end

end