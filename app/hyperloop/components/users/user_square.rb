class UserSquare < Hyperloop::Component
  param user: {}
  # param avatar_url: nil
  param show_locker: false
  param action_buttons_available: false, nils: true
  param show_indicator: false, nils: true
  param can_redirect: nil

  def render

    if params.user.try(:id).try(:>, 0)
      profile_granted = CurrentUserStore.current_user.present? ? CurrentUserStore.current_user.private_photo_permitted.profile_granted.where_owner(params.user.id).first : nil
      profile_requested = CurrentUserStore.current_user.present? ? CurrentUserStore.current_user.private_photo_permitted.profile_requested.where_owner(params.user.id).first : nil

      div(class: 'col-6 col-md-3 col-lg-3 col-xl-3') do
        div(class: "person #{'locked' if params.show_locker}") do
          EroLink(to: "/profile/#{params.user.id}", disabled: (params.can_redirect == false || !!params.user.try(:is_private)) ) do
            div(class: 'person-photo-wrapper') do

              if params.show_indicator
                div(class: 'person-indicator')
              end

              div(class: 'person-actions') do
                if params.action_buttons_available
                  action_buttons
                else
                  # if should_display_access_button(profile_granted, profile_requested)

                  if params.user.try(:is_private) && CurrentUserStore.current_user && !(CurrentUserStore.current_user.is_admin || params.user.id.to_i == CurrentUserStore.current_user_id.to_i || profile_granted.present? || profile_requested.present?)
                    RequestAccessButton(owner: params.user)
                  end
                end
              end

              if params.user && params.user.photos_count && params.user.photos_count.to_i > 0
                div(class: 'person-photo-amount d-none d-md-flex') do
                  i(class: 'ero-photo-amount')
                  span(class: 'amount') {"#{params.user.photos_count}"}
                end
              end

              div(class: 'locker') do
                i(class: 'ero-locker')
              end

              img(src: params.user.try(:avatar_url).present? && params.user.try(:avatar_url).loaded? ? params.user.try(:avatar_url) : params.user.try(:avatar_url).loaded? ? '/assets/user-blank.png' : '' )
              # if !CurrentUserStore.current_user
              # elsif params.user.is_private && CurrentUserStore.current_user && !CurrentUserStore.current_user.is_admin && !can_view_profile && params.user.id.to_i != CurrentUserStore.current_user_id.to_i
              #   img(src: (params.user.avatar_url("blurred") || '/assets/user-blank.png'))
              # else
              #   img(src: (params.user.avatar_url || '/assets/user-blank.png'))
              # end
            end
          end.on(:click) do |e|
            if params.show_locker
              e.prevent_default
              e.stop_propagation
              RequestAccess.run(owner_id: params.user.id, type: 'profile')
              .then do |response|
                `toast.dismiss(); toast.success("Prośba została wysłana.", { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
              end
              .fail do |error|
                `toast.error("Przepraszamy, wystąpił błąd.")`
              end
            # elsif params.can_redirect
            #   AppRouter.push("/profile/#{params.user.id}")
            end
          end

          div(class: 'person-info d-flex align-items-start justify-content-start') do
            UserDescriptor(user: params.user, show_status: true, show_verification: true, show_two_lined: true, show_city: true)
          end.on(:click) do
            if params.show_locker
              RequestAccess.run(owner_id: params.user.id, type: 'profile')
              .then do |response|
                `toast.dismiss(); toast.success("Prośba została wysłana.", { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
              end
              .fail do |error|
                `toast.error("Przepraszamy, wystąpił błąd.")`
              end
            elsif params.can_redirect == true || !params.user.try(:is_private)
              AppRouter.push("/profile/#{params.user.id}")
            end
          end

        end
      end
    end
  #   .while_loading do
    #   mocked_user
    # end
  end

  # def should_display_access_button(profile_granted, profile_requested)
  #   if params.user.try(:is_private) && CurrentUserStore.current_user
  #     if CurrentUserStore.current_user.is_admin || params.user.id.to_i == CurrentUserStore.current_user_id.to_i || profile_granted != nil || profile_requested != nil
  #       false
  #     else
  #       true
  #     end
  #   else
  #     false
  #   end
  # end

  # def can_view_profile
  #   CurrentUserStore.current_user.private_photo_permitted.profile_granted.where_owner(params.user.id).first != nil
  # end

  # def profile_access_requested
  #   CurrentUserStore.current_user.private_photo_permitted.profile_requested.where_owner(params.user.id).first != nil
  # end

  def mocked_user
    div(class: "person opacity-03") do
      div(class: 'person-photo-wrapper') do
        div(class: 'person-photo-amount d-none d-md-flex') do
          i(class: 'ero-photo-amount')
          span(class: 'amount') {'1'}
        end
        div(class: 'locker') do
          i(class: 'ero-locker')
        end
        img(src: '/assets/user-blank.png')
      end
      div(class: 'person-info d-flex align-items-start justify-content-start') do
        div(class: 'person-status offline')
        div(class: 'mocked-person-details') do
          div(class: 'mocked-name')
          div(class: 'mocked-age')
          div(class: 'mocked-city')
        end
      end
    end
  end

  # def avatar_url version
  #   if (!params.user.try(:is_private) || can_view_profile) && params.user.try(:avatar_url)
  #     params.user.try(:avatar_url)
  #   elsif params.user.try(:is_private) && params.user.try(:avatar_url, version)
  #     params.user.try(:avatar_url, version)
  #   else
  #     '/assets/user-blank.png'
  #   end
  # end

  def action_buttons
    button(class: 'btn icon-only btn-person btn-heart btn-group mr-2', type: "button") do
      i(class: 'ero-heart')
    end.on :click do
      AcceptWantToMeet.run(user_id: params.user.id).then do |response|
        GetRoomUserForContextAndJoin.run({ context_type: 'User', context_id: params.user.try(:id), user_id: params.user.try(:id) })
        .then do |room_user|
          ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static', initial_room_user_id: room_user.try(:id), is_paired: true })
        end.catch do |e|
          `toast.error('Nie udało się otworzyć czatu...')`
        end
      end.fail do |error|
        `toast.error("Ooops! Coś poszło nie tak.")`
      end
    end
    button(class: 'btn icon-only btn-person btn-remove btn-group', type: "button") do
      i(class: 'ero-cross')
    end.on(:click) do |e|
      e.prevent_default
      e.stop_propagation
      remove_want_to_meet(params.user.id)
    end
  end

  def remove_want_to_meet(id)
    RemoveWantToMeet.run(user_id: id).then do |response|
      `toast.dismiss(); toast.success("Udało się usunąć!", { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
    end.fail do |error|
      puts "error", error
      `toast.error("Nie udało się usunąć.")`
    end
  end

end