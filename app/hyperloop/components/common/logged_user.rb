class LoggedUser < Hyperloop::Component

  state :user

  before_mount do
    if CurrentUserStore.current_user_id
      mutate.user User.find(CurrentUserStore.current_user_id)
    end
  end

  after_mount do
    if CurrentUserStore.current_user_id.blank?
      CurrentUserStore.on_current_user_load(proc do
        mutate.user User.find(CurrentUserStore.current_user_id)
      end)
    end
  end

  def render
    if state.user.present?
      render_logged_view
    else
      render_not_logged_view
    end
  end

  def render_logged_view
    div(class: "logged-in") do
      div(class: "logged-in-tablet-buttons d-none d-md-flex d-xl-none") do
        button(class: "btn btn-outline-primary btn-outline-gray btn-messages icon-only with-label", type: "button") do
          i(class: "ero-messages")
          # Hyperloop::Model.load do
          #   state.user.try(:room_users)
          # end.then do |data|
          #   if data.present? && (sum = data.inject(0) { |sum, p| sum + (p.unread_counter || 0) }) > 0
          #     span(class: "button-label") { sum.to_s }
          #   end
          # end
        end
        div(class: 'divider')
        button(class: 'btn icon-only btn-outline-primary btn-outline-gray ', type: 'button') do
          i(class: "ero-log-out")
        end.on :click do |e|
          log_out(e)
        end
        div(class: 'divider')
      end

      div(class: 'profile') do
        EroLink(to: "/profile/#{CurrentUserStore.current_user_id}") do
          img(src: user_photo, class: 'user-avatar')
        end
        div(class: 'profile-link-wrapper') do
          div(class: 'profile-link') do

            EroLink(to: "/profile/#{CurrentUserStore.current_user_id}") do
              span() {state.user.try(:name)}
              if state.user.try(:name_second_person).present?
                span() {", #{state.user.try(:name_second_person)}"}
              end
            end
            button(class: 'btn btn-outline-primary btn-outline-gray icon-only d-xl-none fadeable ml-2', type: "button") do
              i(class: 'ero-log-out')
            end.on :click do |e|
              log_out(e)
            end
          end
          a(class: 'profile-log-out text-secondary-i f-s-12 underline d-none d-xl-block') do
            'Wyloguj się'
          end.on :click do |e|
            log_out(e)
          end
        end
      end

      div(class: 'divider')
    end
  end

  def render_not_logged_view
    span do
      div(class: 'logged-out') do
        a(class: 'text-secondary text-ellipsis mt-0 f-s-16 join-us') do
          'Dołącz do nas!'
        end.on :click do |e|
          register
        end
        p(class: 'text-ellipsis mt-0 mb-0') do
          span(class: 'text-gray text-book f-s-13-5') { 'Masz już konto? ' }
          a(class: 'text-primary f-s-13-5') { 'Zaloguj się' }.on :click do |e|
            e.prevent_default
            e.stop_propagation
            open_log_in_modal
          end
        end
      end

      div(class: 'logged-out-mini') do
        button(class: 'btn icon-only btn-outline-primary btn-outline-gray ', type: 'button') do
          i(class: 'ero-user f-s-20')
        end.on :click do |e|
          e.prevent_default
          e.stop_propagation
          open_log_in_modal
        end
      end
    end
  end

  def open_log_in_modal
    # ModalsService.open_modal('LoginModal', { callback: proc{ register() } })
    puts 'WILL OPEN LOGIN MODAL'
    ModalsService.open_modal('LoginModal', {})
    puts 'AFTER OPENING'
  end

  def log_out(event)
    event.prevent_default()
    ProcessLogout.run
    .then do
      # CurrentUserStore.current_user_id! nil
      `toast.dismiss(); toast.success('Wylogowaliśmy Cię z EroTrip.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
    end
    .fail do
      `toast.error('Nie udało się wylogować.')`
    end
  end

  def register
    ModalsService.open_modal('RegistrationModal')
  end

  def user_photo
    if state.user.try(:my_avatar_url) && state.user.try(:my_avatar_url).try(:loaded?)
      state.user.my_avatar_url
    elsif state.user.try(:my_avatar_url).try(:loaded?)
      return '/assets/user-blank.png'
    else
      # means loading
      ''
    end
  end

end

