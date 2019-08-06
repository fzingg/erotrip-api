class MessengerMessages < Hyperloop::Component
  param :active_room_user
  # param :last_message_id
  param :activate_room_user
  # param :is_paired
  # state :active_room
  param :my_messages
  param is_permitted: nil, nils: true
  param :delete_my_messages
  param :close

  # state :img_addon

  # before_receive_props do |new_props|
  #   puts "MESSAGES: NEW PROPS CAME IN! #{new_props}"
  #   # if params.active_room_user.present? && new_props[:is_permitted].present? && new_props[:is_permitted] != params.is_permitted
  #   #   mutate.img_addon Time.now.to_i
  #   # end
  # end

  after_update do
    if `$('#messenger-chat-wrapper').length > 0`
      `$('#messenger-chat-wrapper').animate({ scrollTop: $('#messenger-chat-wrapper')[0].scrollHeight}, 100);`
    end
  end

  def am_i_permitted_for(other_user_id)
    result = false
    if params.active_room_user.present? && params.active_room_user.try(:loaded?)
      me_id = CurrentUserStore.current_user_id

      permission = AccessPermission.profile_granted.where_owner(other_user_id).where_permitted(me_id).first
      result = true if permission.try(:loaded?) && permission.present?

      if !result
        if params.active_room_user.room_hotline_id.present?
          permission = HotlineAccessPermission.ransacked({
            is_permitted: true,
            hotline_id_eq: params.active_room_user.room_hotline_id,
            owner_id_eq: other_user_id,
            permitted_id: me_id
          })
          result = true if permission.try(:loaded?) && permission.count > 0
        elsif params.active_room_user.room_trip_id.present?
          permission = TripAccessPermission.ransacked({
            is_permitted: true,
            trip_id_eq: params.active_room_user.room_trip_id,
            owner_id_eq: other_user_id,
            permitted_id: me_id
          })
          result = true if permission.try(:loaded?) && permission.count > 0
        end
      end
    end
    result
  end

  def open_messenger user
    mutate.main_blocker true
    GetRoomUserForContextAndJoin.run({ context_type: 'Room', context_id: params.active_room_user.room_id, hotline_id: params.active_room_user.room_hotline_id, trip_id: params.active_room_user.room_trip_id, user_id: user.id })
    .then do |room_user|
      mutate.main_blocker false
      # mutate.active_room CurrentUserStore.current_user.rooms.from_newest.select{|r| r.try(:id) == room['id']}.first
      Hyperloop::Model.load do
        RoomUser.find(room_user['id'])
      end.then do |fetched_room_user|
        # mutate.active_room fetched_room
        # mutate.active_room fetched_room
        params.activate_room_user.call fetched_room_user
      end.fail do |err|
        puts "CANNOT LOAD DATA 90 - #{err}"
        `toast.error('Nie udało się rozpocząć czatu...')`
      end
    end.catch do |e|
      puts e.inspect
      mutate.main_blocker false
      `toast.error('Nie udało się rozpocząć czatu...')`
    end
  end

  def should_autoscroll? scrollHeight, scrollTop, offsetHeight
    if scrollHeight == scrollTop + offsetHeight
      return true
    else
      return false
    end
  end

  def open_full_image image_url

  end

  def react_to_new_message
    if should_autoscroll? `$('#messenger-chat-wrapper')[0].scrollHeight`, `$('#messenger-chat-wrapper')[0].scrollTop`, `$('#messenger-chat-wrapper')[0].offsetHeight`

      if RUBY_ENGINE == 'opal'
        `setTimeout(function(){
          $('#messenger-chat-wrapper').animate({ scrollTop: $('#messenger-chat-wrapper')[0].scrollHeight}, 0)
        }, 2500)`
      end
    end
  end

  def display_messages_as_boxes
    (params.active_room_user.try(:is_trip_grouped?) || params.active_room_user.try(:is_hot_grouped?)) && (params.active_room_user.try(:dependent_resource_owner_id) == CurrentUserStore.current_user_id)
  end

  def render
    if params.active_room_user.blank? || !params.active_room_user.try(:archived_at).try(:loaded?)
      messages_scope = []
    elsif display_messages_as_boxes
      messages_scope = Message.for_room(params.active_room_user.room_id).from_newest.preload_user
    elsif params.active_room_user.try(:is_trip_grouped?) || params.active_room_user.try(:is_hotline_grouped?)
      messages_scope = Message.for_room(params.active_room_user.room_id).for_user(CurrentUserStore.current_user_id).preload_user
    else
      messages_scope = Message.for_room(params.active_room_user.room_id).preload_user
    end

    # .created_after(params.active_room_user.try(:archived_at))

    if params.my_messages.length > 0 && params.my_messages.last.try(:content) == messages_scope.last.try(:content) && messages_scope.last.try(:content).try(:loaded?)
      params.delete_my_messages.call
    end

    div(class: 'messenger-chat-wrapper', id: 'messenger-chat-wrapper') do

      if params.active_room_user.present?


        div(class: "#{'hidden' if messages_scope.try(:loaded?)}") do
          div(class: 'dots-container') do
            div(class: 'animated-dots') do
              span {'.'}
              span {'.'}
              span {'.'}
            end
          end
        end


        if display_messages_as_boxes
          div(class: "messenger-chat no-padding as-boxes #{'hidden' if !messages_scope.try(:loaded?)}") do
            messages_scope.each do |message|
              div(class: 'message-user-wrapper') do
                div(class: "message-wrapper") do
                  div(class: 'message-profile-picture') do
                    if (params.active_room_user.is_trip_grouped? || params.active_room_user.is_hot_grouped?) && params.active_room_user.dependent_resource_owner_id == CurrentUserStore.current_user_id
                      img(src: message.user.try(:avatar_url) ? "#{message.user.try(:avatar_url)}#{am_i_permitted_for(message.try(:user_id)) ? '1' : '0'}" : '/assets/user-blank.png')
                    else
                      img(src: params.active_room_user.try(:opposite_user_avatar_url) ? "#{params.active_room_user.try(:opposite_user_avatar_url)}#{params.is_permitted ? '1' : '0'}" : '/assets/user-blank.png')
                    end
                  end
                  if message.content && message.content.size > 0
                    div(class: 'message') do
                      UserDescriptor(
                        user: message.try(:user),
                        show_status: true,
                        show_verification: false,
                        show_two_lined: false,
                        show_city: false
                      )
                      div { message.content }
                    end
                  elsif message.has_photo? && message.thumbnail_url
                    a() do
                      UserDescriptor(
                        user: message.try(:user),
                        show_status: true,
                        show_verification: false,
                        show_two_lined: false,
                        show_city: false
                      )
                      img(class: 'message', onLoad: proc { `$('#messenger-chat-wrapper').animate({ scrollTop: $('#messenger-chat-wrapper')[0].scrollHeight}, 100);` }, src: message.thumbnail_url)
                    end.on :click do
                      open_full_image message.url
                    end
                  end
                end.on :click do
                  if (params.active_room_user.try(:room_hotline_id).present? || params.active_room_user.try(:room_trip_id).present?) && params.active_room_user.try(:room_room_id).blank? && (params.active_room_user.try(:dependent_resource_owner_id) == CurrentUserStore.current_user_id)
                    # open_messenger message.user
                    if am_i_permitted_for(message.try(:user_id))
                      AppRouter.push "/profile/#{params.active_room_user.try(:room).try(:opposite_user).try(:id)}?hot=#{params.params.active_room_user.try(:room).try(:hotline_id)}&trip=#{params.active_room_user.try(:room).try(:trip_id)}"
                      params.close.call
                    else
                      open_messenger message.user
                    end
                  end
                end
              end
            end
          end
        else

          div(class: "messenger-chat #{'hidden' if !messages_scope.try(:loaded?)}") do


            messages_scope.chunk { |p| "#{p[:user_id]}:#{p[:system_kind]}" }.each do |user_id_with_kind, array|

              user_id = user_id_with_kind.split(':')[0]
              system_kind = user_id_with_kind.split(':')[1]

              if system_kind.present?
                array.each do |message|

                  if message.system_kind != 'paired'
                    div(class: 'message-user-wrapper') do
                      div(class: "system_message") {
                        div(class: "message-icon") do
                          if ['hotline_access_permission_granted', 'trip_access_permission_granted', 'access_permission_granted', 'private_photos_granted'].include?(message.system_kind)
                            i(class: 'ero-unlocked')
                          elsif ['hotline_access_permission_rejected', 'trip_access_permission_rejected', 'access_permission_rejected', 'private_photos_rejected'].include?(message.system_kind)
                            i(class: 'ero-locker')
                          end
                        end
                        message.system_description
                      }
                    end
                  else
                    div(class: 'messenger-chat-is-paried d-flex align-items-center text-center') do
                      div do
                        div(class: 'parried-avatars mb-3') do
                          div(class: 'parried-heart') do
                            i(class: 'ero-heart f-s-25')
                          end
                          div(class: 'parried-avatar') do
                            # user_parried = RoomUser.ransacked({user_id_not_eq: CurrentUserStore.current_user_id, room_id_eq: params.active_room.try(:id)}).first
                            # img(src: user_parried.try(:user).try(:avatar_url) || '/assets/user-blank.png')
                            img(src: params.active_room_user.try(:opposite_user_avatar_url) ? "#{params.active_room_user.try(:opposite_user_avatar_url)}#{params.is_permitted ? '1' : '0'}" : '/assets/user-blank.png')
                          end
                          div(class: 'parried-avatar') do
                            img(src: CurrentUserStore.current_user.try(:avatar_url) || '/assets/user-blank.png')
                          end
                        end

                        h5(class: 'text-gray') do
                          span { message.system_description }
                        end
                      end
                    end
                  end
                end


              else
                div(class: 'message-user-wrapper') do
                  array.each do |message|
                    if message.plain_user_id == CurrentUserStore.current_user_id
                      div(class: "message-wrapper mine") do
                        if message.content && message.content.size > 0
                          div(class: 'message') {message.content}
                        elsif message.has_photo? && message.thumbnail_url
                          a() do
                            img(class: 'message', src: message.thumbnail_url)
                          end.on :click do
                            open_full_image message.url
                          end
                        end
                      end
                    else
                      div(class: "message-wrapper") do
                        div(class: 'message-profile-picture') do
                          # img(src: params.active_room_user.opposite_user_avatar_url || '/assets/user-blank.png')
                          img(src: params.active_room_user.try(:opposite_user_avatar_url) ? "#{params.active_room_user.try(:opposite_user_avatar_url)}#{params.is_permitted ? '1' : '0'}" : '/assets/user-blank.png')
                          # message.user.try(:avatar_url)
                        end
                        if message.content && message.content.size > 0
                          div(class: 'message') {message.content}
                        elsif message.has_photo? && message.thumbnail_url
                          a() do
                            img(class: 'message', onLoad: proc { `$('#messenger-chat-wrapper').animate({ scrollTop: $('#messenger-chat-wrapper')[0].scrollHeight}, 100);` }, src: message.thumbnail_url)
                          end.on :click do
                            open_full_image message.url
                          end
                        end
                      end.on :click do
                        if (params.active_room_user.try(:room_hotline_id).present? || params.active_room_user.try(:room_trip_id).present?) && params.active_room_user.try(:room_room_id).blank? && (params.active_room_user.try(:dependent_resource_owner_id) == CurrentUserStore.current_user_id)
                          if is_permitted
                            AppRouter.push "/profile/#{params.active_room_user.try(:room).try(:opposite_user).try(:id)}?hot=#{params.params.active_room_user.try(:room).try(:hotline_id)}&trip=#{params.active_room_user.try(:room).try(:trip_id)}"
                            params.close.call
                          else
                            open_messenger message.user
                          end
                        end
                      end
                    end

                  end
                end
              end
            end
            div(class: 'message-user-wrapper') do
              params.my_messages.each do |message|
                div(class: "message-wrapper mine") do
                  if message && message.content.present?
                    div(class: 'message ') {message.content.to_s}
                  elsif message.is_photo
                    img(class: 'message', src: 'http://pressroom.reserved.com/theme/Reserved/img/loading.gif?1481617964')
                  end
                end
              end
            end
            # unless (params.my_messages.last.try(:content).try(:loaded?) || params.my_messages.last.try(:thumbnail_url).try(:loaded?))
          end

        end
      end
    end
  end
end