class GroupsJoinModal < Hyperloop::Component
  include BaseModal

  param group: nil
  state errors: {}
  state public: nil

  after_mount do
    if CurrentUserStore.current_user.blank?
      ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('GroupsJoinModal', { group: params.group }) } } )
      close
    end
  end

  def title
    'Dołącz do grupy'
  end

  def render_modal
    span do
      div(class: 'modal-body text-center') do
        h5 { "Dodaj mnie do grupy" }

        div(class: 'mt-4 mb-4 flex justify-content-center align-items-center') do
          button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125 #{'active' if state.public == true}") do
            'Publicznie'
          end.on :click do
            mutate.public true
          end
          button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125 #{'active' if state.public == false}") do
            'Anonimowo'
          end.on :click do
            mutate.public false
          end
        end

        # p { "Did you read the DaVinci Code or maybe see the movie? Did it get you interested in history and secret" }
      end

      div(class: 'modal-footer') do
        BlockUi(tag: "div", blocking: state.blocking) do
          button(class: 'btn btn-secondary btn-cons mb-3', type: "button") do
            'Dołącz'
          end.on :click do
            join_group
          end
        end
      end
    end
  end

  def join_group
    mutate.blocking true
    SaveUserGroup.run(user_id: CurrentUserStore.current_user.id, group_id: params.group.try(:id), is_public: state.public)
    .then do |saved|
      mutate.blocking false
      `toast.dismiss(); toast.success('Dołączyłeś/aś do grupy!', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      params.callback.call() if params.callback
      close
    end.fail do |error|
      mutate.blocking false
      if error.try(:message).present? && error.try(:message)["group_id"].present?
        `toast.error('Dołączyłeś/aś do tej grupy już wcześniej!')`
        params.callback.call() if params.callback
        close
      else
        `toast.error('Nie udało się dołączyć do grupy!')`
      end
    end
    # SaveGroup.run(state.group)
    # .then do |data|
    #   puts 'THEN'
    #   mutate.blocking false

    #   close
    # end
    # .fail do |e|
    #   mutate.blocking false
    #   `toast.error('Nie udało się zarejestrować.')`
    #   if e.class.name.to_s == 'ArgumentError'
    #     errors = JSON.parse(e.message.gsub('=>', ':'))
    #     errors.each do |k, v|
    #       errors[k] = v.join('; ')
    #     end
    #     mutate.errors errors
    #   elsif e.is_a?(Hyperloop::Operation::ValidationException)
    #     mutate.errors e.errors.message
    #   end
    #   {}
    # end
  end

end