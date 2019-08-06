class MessagesTextBox < Hyperloop::Component
  param message_content: ''
  param :active_room_user
  # param :active_room_user_id
  param :append_message
  param :delete_my_messages

  state :message_content
  state :file_uri
  state message_blocker: false

  before_mount do
    mutate.message_content params.message_content
    mutate.message_blocker false
  end

  def user_types(e)
    if e.key_code == 13 && e.shift_key == false
      if state.message_content.present?
        e.prevent_default
        e.stop_propagation
        send_message
      end
    end
  end

  def send_message
    mutate.message_blocker true
    content_to_send = state.message_content
    mutate.message_content ''
    file_uri = state.file_uri
    params.append_message.call OpenStruct.new(content: content_to_send, is_photo: state.file_uri.present?)
    `document.getElementById('ero-message-textarea').value = ''`
    SendMessage.run(room_id: params.active_room_user.try(:room_id), content: content_to_send, file_uri: file_uri, acting_user: CurrentUserStore.current_user)
    .then do |data|
      `document.getElementById('ero-message-textarea').value = ''`
      mutate.file_uri nil
      mutate.message_blocker false
      # params.delete_my_messages.call
    end
    .fail do |err|
      puts err
      `console.log(err)`
      `document.getElementById('ero-message-textarea').value = #{content_to_send}`
      `toast.error('Nie udało się wysłać wiadomości...')`
      params.delete_my_messages.call
      mutate.message_content content_to_send
      mutate.message_blocker false
    end
  end

  def message_paste event
    `
    console.log(event);
    console.log(event.native.clipboardData.items);
    var items = (event.clipboardData || event.native.clipboardData).items;
    console.log(JSON.stringify(items));
    `
  end

  def message_changed(e)
    mutate.message_content e.target.value
  end

  def message_photo_file_changed data
    mutate.file_uri data
    send_message
  end

  def render
    div(class: 'messenger-textarea') do
      BlockUi(tag: "div", blocking: state.message_blocker) do
        textarea(
          id: 'ero-message-textarea',
          class: 'form-control',
          placeholder: 'Wpisz wiadmość (wciśnij enter, by wysłać)',
          name: 'content',
          defaultValue: state.message_content,
          disabled: !params.active_room_user.try(:can_send_message)
        ).on(:change) { |e| message_changed e }.on(:key_down) { |e| user_types e }.on(:paste) { |e| message_paste e }
        button(
          class: 'btn btn-messenger-upload-photo',
          disabled: !params.active_room_user.try(:can_send_message)
        ) do
          ImageUpload(input_id: "message-photo", can_upload_photo: true, fileChanged: proc { |photo_uri| message_photo_file_changed(photo_uri) }) do
            i(class: 'ero-camera f-s-25')
          end
        end
      end
    end
  end
end