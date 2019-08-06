class LoginModal < Hyperloop::Component
  include BaseModal

  state credentials: {}
  state errors: {}

  def render_modal
    if CurrentUserStore.current_user.present?
      render_logged_view
    else
      render_not_logged_view
    end
	end

	def title
    'Zaloguj się'
  end

  after_mount do
    # after 1 do
    #   refs['passInput'].click unless refs['passInput'].nil?
    #   refs['loginInput'].click unless refs['loginInput'].nil?
    # end
  end

  def render_not_logged_view
    span do
      div(class: 'modal-body modal-body-login') do
        if (state.errors || {})['error'].present?
          div(class: "alert alert-danger") do
            (state.errors || {})['error']
          end
        end
        # p { "#{state.errors.inspect}" }
        form(ref: 'loginForm') do
					FormGroup(label: "Adres e-mail", error: state.errors['error'], hide_error_message: true) do
						input(ref: 'loginInput', defaultValue: state.credentials['email'], type: "email", class: "form-control #{'is-invalid' if (state.errors || {})['email'].present?}", placeholder: "Adres e-mail").on :key_up do |e|
                puts 'INPUT FIRED'
                mutate.credentials['email'] = e.target.value
                mutate.errros {}
              end
            end

					FormGroup(label: "Hasło", error: state.errors['error'], hide_error_message: true) do
						input(ref: 'passInput', defaultValue: state.credentials['password'], type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['password'].present?}", placeholder: "Hasło").on :key_up do |e|
                puts 'INPUT FIRED'
                mutate.credentials['password'] = e.target.value
                mutate.errros {}
              end
            end

          div(class: 'text-center') do
            div do
              state.blocking
            end
            BlockUi(tag: "div", blocking: state.blocking) do
              button(class: 'btn btn-secondary btn-cons mt-4 mb-4', type: "submit") do
                'Zaloguj się'
              end
            end
          end
        end.on :submit do |e|
          e.prevent_default
          puts "refs['loginForm'].serialize(): #{refs['loginForm'].serialize()}"
          unless refs['passInput'].nil?
            puts "refs['passInput'].value: #{refs['passInput'].value}"
            mutate.credentials['password'] = refs['passInput'].value
          end
          unless refs['loginInput'].nil?
            puts "refs['loginInput'].value: #{refs['loginInput'].value}"
            mutate.credentials['email'] = refs['loginInput'].value
          end
          log_in
        end
        p(class: 'text-center') do
          span {'Nie pamiętasz hasła? '}
          a(class: 'text-primary') do
            'Zrestartuj hasło'
          end.on :click do |e|
            reset_password
          end
        end
        p(class: "text-center") do
          span {'Nie masz konta? '}
          a(class: 'text-secondary') do
            'Zarejestruj się'
          end.on :click do |e|
            register
          end
        end
      end
    end
  end

  def render_logged_view
    span do
      div(class: 'modal-body') do
        p(class: 'text-center') { 'Super! Jesteś zalogowany' }
      end
      div(class: 'modal-footer text-center') do
        button(class: 'btn btn-secondary btn-cons mt-3 mb-3', type: "button") do
          'Zamknij okno'
				end.on :click do
					params.callback.call() if params.callback
          close
        end
      end
    end
  end

  def log_in
    unless state.blocking
      mutate.blocking(true)
      mutate.errors {}
      ProcessLogin.run(email: state.credentials['email'], password: state.credentials['password'])
        .then do |response|
          mutate.blocking(false)
          params.callback.call(true) if params.callback
          close
        end
        .fail do |e|
          `toast.error('Nie udało się zalogować')`
          mutate.blocking(false)
          if e.is_a?(Exception) && e.message.present?
            mutate.errors({ error: e.message })
            # elsif e.is_a?(HTTP)
            #   if JSON.parse(e.body)['id'].present?
            #     CurrentUserStore.current_user_id! JSON.parse(e.body)['id']
            #     if RUBY_ENGINE == 'opal'
            #       `setTimeout(function(){
            #         $('#login-modal').modal('hide')
            #       }, 1000)`
            #     end
            #   end
            #   mutate.errors JSON.parse(e.body)['errors']
          end
          if e.is_a?(Hyperloop::Operation::ValidationException)
            mutate.errors e.errors.message
          end
          {}
        end
    end
  end

  def register
    ModalsService.open_modal('RegistrationModal', { callback: params.callback })
    close
  end

  def reset_password
    ModalsService.open_modal('ResetPasswordModal', { callback: params.callback })
    close
  end

end

