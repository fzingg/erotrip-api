class Messenger < Hyperloop::Component
  include BaseModal

  param initial_room_user_id: nil
  param initial_message: ''
  param is_paired: false, nils: true

  state active_room_user: nil
  state message_content: ''

  state my_messages: []

  state :chat_scroller

  state last_message_id: ''
  state autoscroll: true
  state scroll_position: ''

  state initial_animation: true
  state is_paired: true

  state message_size: ''

  state current_filter: 'all'
  state current_timestamp: nil

  state initial_room_user_set: 0

  @initial = true

  before_mount do
    if params.initial_message.present?
      mutate.message_content params.initial_message
    end

    if params.initial_room_user_id.present? && params.initial_room_user_id.to_i > 0
      mutate.initial_room_user_set params.initial_room_user_id.to_i
    end
  end

  after_mount do
    `document.querySelector('.modal-backdrop').classList.add('messenger-backdrop')`

    # this 1st if never works in new heperloop (?) so I've added an 'else'
    # if params.initial_room.present?
    #   # NEED TO DOWNLOAD ROOM DUE TO ERRORS WHILE INITIALIZING NEW ONE FROM HASH
    #   if params.initial_room.class.to_s == 'Hash'
    #     mutate.active_room Room.find(params.initial_room['id'])
    #   else
    #     mutate.active_room params.initial_room
    #   end
    # else
    # end
    # mutate.active_room CurrentUserStore.current_user.rooms.from_newest.first


    # params.is_paired.present? ? mutate.is_paired(true) : mutate.is_paired(false)
  end

  after_update do
    # handle_unread_counter
  end

  def initial_animate
    if state.initial_animation
      mutate.initial_animation false
      if RUBY_ENGINE == 'opal'
        `setTimeout(function(){
          $('#messenger-chat-wrapper').animate({ scrollTop: $('#messenger-chat-wrapper')[0].scrollHeight}, 0)
        }, 2500)`
      end
    end.fail
  end

  def handle_unread_counter
    # Hyperloop::Model.load do
    #   CurrentUserStore.current_user.room_users
    # end.then do |room_users|
    #   if state.active_room_user.present? && (((room_user = room_users.select{ |ru| ru.room_id == state.active_room.id }.first).try(:unread_counter) || 0) > 0)
    #     ResetUnreadCounter.run(room_user_id: room_user.try(:id))
    #   end
    #   # if state.active_room.present? && (((room_user = room_users.select{ |ru| ru.room_id == state.active_room.id }.first).try(:unread_counter) || 0) > 0)
    #   #   ResetUnreadCounter.run(room_user_id: room_user.try(:id))
    #   # end
    # end.fail do |err|
    #   puts "CANNOT LOAD DATA 47 - #{err}"
    # end
    if state.active_room_user.present? && (state.active_room_user.try(:unread_counter) || 0) > 0
      ResetUnreadCounter.run(room_user_id: state.active_room_user.try(:id))
    end
  end

  def alert_user user
    ModalsService.open_modal('UserAlert', { size_class: 'modal-md', resource_id: user.try(:id), resource_type: 'User' })
  end

  def activate_room_user room_user_id
    mutate.active_room_user nil
    mutate.initial_room_user_set room_user_id
  end

  def delete_my_messages
    mutate.my_messages []
    # after(0) do
    # end
  end

  def append_message message
    messages = state.my_messages
    messages.push message
    mutate.my_messages messages
  end

  def am_i_permitted
    result = false
    if state.active_room_user.present? && state.active_room_user.try(:loaded?)
      me_id = CurrentUserStore.current_user_id

      if (state.active_room_user.is_hot_grouped? || state.active_room_user.is_trip_grouped?) && state.active_room_user.dependent_resource_owner_id == me_id
        return true
      end

      other_user_id = (state.active_room_user.room_user_ids - [me_id]).first

      permission = AccessPermission.profile_granted.where_owner(other_user_id).where_permitted(me_id).first
      result = true if permission.try(:loaded?) && permission.present?

      if !result
        if state.active_room_user.room_hotline_id.present?
          permission = HotlineAccessPermission.ransacked({
            is_permitted: true,
            hotline_id_eq: state.active_room_user.room_hotline_id,
            owner_id_eq: other_user_id,
            permitted_id: me_id
          })
          result = true if permission.try(:loaded?) && permission.count > 0
        elsif state.active_room_user.room_trip_id.present?
          permission = TripAccessPermission.ransacked({
            is_permitted: true,
            trip_id_eq: state.active_room_user.room_trip_id,
            owner_id_eq: other_user_id,
            permitted_id: me_id
          })
          result = true if permission.try(:loaded?) && permission.count > 0
        end
      end
    end
    result
  end

  def request_data_for_room_user room_user
    room_user.updated_at
    room_user.room_id
    room_user.user_id
    room_user.unread_counter
    room_user.is_opposite_user_matched
    room_user.can_send_message
    room_user.room_last_message_id
    room_user.room_updated_at
    room_user.room_trip_id
    room_user.room_hotline_id
    room_user.room_room_id
    room_user.room_owner_id
    room_user.room_user_ids
    room_user.is_trip_anonymous
    room_user.is_hotline_anonymous
    room_user.dependent_resource_owner_id
    room_user.opposite_user_avatar_url
    room_user.room_name
    room_user.room_description
    room_user.archived_at
    room_user.id
    nil
  end

  def render_modal
    div(class: 'modal-body messenger-body') do

      # sidebar start
      # MessengerSidebar(active_room_id: state.active_room.try(:id), activate_room: proc{ |room| activate_room room })
      div(class: "messenger-sidebar #{ 'slide-left' if !state.active_room_user.blank? }") do

        # MESSAGE TABS
        div(class: 'messenger-filters') do
          div(class: "messenger-filters-tab all #{ 'active' if state.current_filter == 'all' }") do
            span {'Wszyscy'}
          end.on :click do
            mutate.current_filter 'all'
          end
          div(class: "messenger-filters-tab trips #{ 'active' if state.current_filter == 'trip' }") do
            span {'Przejazdy'}
          end.on :click do
            mutate.current_filter 'trip'
          end
          div(class: "messenger-filters-tab #{ 'active' if state.current_filter == 'hotline' }") do
            span {'Hotline'}
          end.on :click do
            mutate.current_filter 'hotline'
          end
          div(class: "messenger-filters-dot #{ 'active' if state.current_filter == 'status' }") do
            div(class: "person-status")
          end.on :click do
            mutate.current_filter 'status'
            mutate.current_timestamp Time.now
          end
        end

        # MESSAGE LIST
        div(class: 'messenger-list-wrapper') do
          div(class: 'messenger-list') do
            # room_users_scope = Room.for_user(CurrentUserStore.current_user_id).for_filter(state.current_filter, CurrentUserStore.current_user_id).from_newest

            room_users_scope = RoomUser.visible.for_user(CurrentUserStore.current_user_id).for_filter(state.current_filter, CurrentUserStore.current_user_id).from_newest.preload_room_data

            if state.initial_room_user_set != true && room_users_scope.try(:loaded?) && room_users_scope.try(:[], 0).present? && state.active_room_user.blank?
              if state.initial_room_user_set.to_i > 0
                candidate = room_users_scope.select{ |ru| ru.id == state.initial_room_user_set.to_i }.try(:first)
                if candidate.present?
                  mutate.active_room_user candidate
                end
              else
                mutate.active_room_user room_users_scope.try(:[], 0)
                mutate.initial_room_user_set true
              end
            elsif state.active_room_user.present? && !room_users_scope.map(&:id).include?(state.active_room_user.try(:id))
              mutate.active_room_user room_users_scope.try(:[], 0)
            end

            div(class: "#{'hidden' unless room_users_scope.try(:loaded?)}") do
              room_users_scope.each do |room_user|
                request_data_for_room_user(room_user)

                if room_user.try(:loaded?) && !should_hide_room_user(room_user, room_users_scope)
                  #  && room_user.try(:room).try(:loaded?) && room_user.try(:opposite_user).try(:loaded?)
                  # room_users_scope.each do |room|
                  # CurrentUserStore.current_user.rooms.from_newest.each do |room|
                  MessengerSidebarElement(
                    # active_room_user_id: state.active_room_user.try(:id),
                    is_active: state.active_room_user.try(:id) == room_user.try(:id),
                    room_user: room_user,
                    room_user_updated: room_user.try(:updated_at).to_i,
                    is_permitted: (state.active_room_user.try(:id) == room_user.try(:id) ? am_i_permitted : nil),
                    # is_permitted: am_i_permitted,
                    on_click: proc{ activate_room_user room_user.try(:id) }
                  )
                end
              end
            end
            div(class: "#{'hidden' if room_users_scope.try(:loaded?)}") do
              div(class: 'dots-container') do
                div(class: 'animated-dots') do
                  span {'.'}
                  span {'.'}
                  span {'.'}
                end
              end
            end

          end
        end

        # SEARCH
        div(class: 'messenger-search') do
          input(class: 'form-control', placeholder: 'Szukaj', type: 'text')
          button(class: 'btn btn-messenger-search') do
            i(class: 'ero-search')
          end
        end
      end
      # sidebar end

      # messenger main start
      div(class: 'messenger-main') do
        button(class: 'btn btn-messenger-close') do
          i(class: 'ero-cross rotated-45deg')
        end.on :click do
          close
        end
        if state.active_room_user.try(:loaded?)
          # && state.active_room_user.try(:room).try(:loaded?) && state.active_room_user.try(:room).try(:opposite_user).present?
          # && state.active_room_user.try(:room).try(:opposite_user).try(:loaded?)
          MessengerHeader(
            active_room_user: state.active_room_user,
            close: proc{close},
            is_permitted: am_i_permitted,
            activate_room_user: proc{ |ru| activate_room_user ru.try(:id) }
          )

          MessengerMessages(
            active_room_user: state.active_room_user,
            # last_message_id: state.last_message_id,
            is_permitted: am_i_permitted,
            activate_room_user: proc{|room_user| activate_room_user room_user.try(:id)},
            my_messages: state.my_messages,
            delete_my_messages: proc{delete_my_messages},
            close: proc{close},
            # is_paired: state.is_paired
          )

          div(class: 'messenger-verified-user-first-message d-none') do

            div(class: 'messenger-verified-img') do
              img(src: '/assets/girl.jpg')
              div(class: 'messenger-verified-circle') do
                i(class: 'ero-checkmark')
              end
            end

            div(class: 'messenger-verified-text') {'ohaio'}
          end

          div(class: 'messenger-chat-warning d-none') do
            div(class: 'locker-big') do
              i(class: 'ero-locker f-s-65')
            end
            p(class: 'text-center f-s-18 text-book mt-4 mb-4') do
              span {'Emilia ukryła profil, poczekaj aż nawiąże'}
              br
              span {'z Tobą kontakt lub:'}
            end
            button(class: 'btn btn-primary btn-lg', type: 'button') {'Wyślij zaczepkę'}
          end

          div(class: 'messenger-chat-warning d-none') do
            div(class: 'image-with-locker') do
              img(src: '/assets/girl.jpg')
              div(class: 'locker') do
                i(class: 'ero-locker f-s-25')
              end
            end
            p(class: 'text-center f-s-18 text-book mt-4 mb-4') do
              span(class: 'text-medium') {'Joanna, 24 prosi o kontakt,'}
              span {'jeśli chcesz kontynuować'}
              br
              span {'rozmowę wyślij wiadomość lub odpowiedz na zaczępkę:'}
            end
            button(class: 'btn btn-primary btn-lg', type: 'button') {'Wyślij zaczepkę'}
          end

          unless ((state.active_room_user.try(:room_hotline_id) || state.active_room_user.try(:room_trip_id)) && !state.active_room_user.try(:room_room_id)) && (CurrentUserStore.current_user_id == state.active_room_user.try(:dependent_resource_owner_id))
            MessagesTextBox(
              message_content: state.message_content,
              active_room_user: state.active_room_user,
              append_message: proc{|mes| append_message mes},
              delete_my_messages: proc{delete_my_messages}
            )
          end
        end

        # messenger main end
      end

    end
  end

  def render
    div(id: id, class: "modal fadeable", role: "dialog", tabIndex: "-1", "data-keyboard" => "false") do
      div(class: "modal-dialog #{params.size_class}", role: "document") do
        div(class: 'modal-content') do
          render_modal
        end
      end
    end
  end

  def should_hide_room_user(room_user, all)
    if room_user.is_trip_grouped? && room_user.dependent_resource_owner_id != CurrentUserStore.current_user_id
      all.select{ |ru| ru.room_trip_id == room_user.room_trip_id && ru.room_room_id.present? }.size > 0
    elsif room_user.is_hot_grouped? && room_user.dependent_resource_owner_id != CurrentUserStore.current_user_id
      all.select{ |ru| ru.room_hotline_id == room_user.room_hotline_id && ru.room_room_id.present? }.size > 0
    else
      false
    end
  end

  def title
    nil
  end

end