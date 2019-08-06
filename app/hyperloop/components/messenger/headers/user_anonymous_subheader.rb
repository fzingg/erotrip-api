class MessengerSubheaderForAnonymousUser < Hyperloop::Component

  param :active_room_user
  param :unlock_for_opposite


  def render

    # explicit_permission = AccessPermission.where_owner(CurrentUserStore.current_user_id).where_permitted_for_room(active_room_user.room_id).granted_for_room(active_room_user.room_id).first.present?

    div(class: "messenger-header messenger-user-anonymous") do
      "Aktualnie jesteś anonimowy, kliknij tutaj, aby się pokazać."
      # div(class: 'g-wrapper') do

      #   # IMAGE
      #   div(class: 'g-image-wrapper') do
      #     img(src: CurrentUserStore.current_user.try(:avatar_url) || '/assets/user-blank.png')
      #     if true
      #       div(class: 'g-image-locker') do
      #         i(class: 'ero-locker')
      #       end
      #     end
      #   end

      #   # DESCRIPTION
      #   div(class: 'g-description-wrapper') do

      #     div(class: 'g-description mr-4 mt-1') do
      #       p(class: 'mb-0') { "Aktualnie jesteś anominowy." }
      #       p(class: 'mb-0') { "Pokaż się w dowolnym momencie."}
      #     end
      #   end
      # end

      # button(class: 'btn btn-secondary btn-unlock', type: 'button') do
      #   if false #explicit_permission
      #     span {'Ukryj się'}
      #   else
      #     span {'Pokaż się'}
      #   end
    end.on :click do
      params.unlock_for_opposite.call
    end

  end


end