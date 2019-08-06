class GroupSingle < Hyperloop::Component

  PRIVACY_OPTIONS = [
    {label: 'Publiczny', value: 'is_public'},
    {label: 'Prywatny',  value: 'is_private'}
  ]

  param group: nil
  param user_group: nil
  param blue_bordered_button: false, nils: true
  param on_remove_init: nil
  param about_to_remove: false
  param redirect_after_destroy: false


  state selected_privacy: PRIVACY_OPTIONS[0][:value]
  state is_public:     nil
  state should_update: true

  def render
    div(class: "group-card-wrapper #{'dark-overlay' if !!params.about_to_remove}") do

      EroLink(to: "/groups/#{params.group.try(:id)}", disabled: !!params.about_to_remove) do
        div(class: "remove-wrapper #{'shown' if !!params.about_to_remove }") do
          button(class: "btn icon-only btn-container text-secondary white-border white-bg remove-btn", type: "button") do
            i(class: 'ero-trash f-s-22 text-secondary')
          end.on :click do |e|
            confirm_deletion params.group, e
          end
          span(class: "text-white f-s-18") {'Usuń grupę'}
        end

        div(class: "group-mobile-photo-container") do
          div(class: 'group-img') do
            if indicator_count && indicator_count > 0
              div(class: 'group-indicator') do
                span { indicator_count.to_s }
              end
            end
            img(src: params.group.try(:photo_url) || '/assets/group-blank.png')
          end
        end

        div(class: "group-card") do

          # 1st element
          div(class: 'group-img') do
            if indicator_count && indicator_count > 0
              div(class: 'group-indicator') do
                span { indicator_count.to_s }
              end
            end
            img(src: params.group.try(:photo_url) || '/assets/group-blank.png')
          end

          # 2nd element
          group_action_button(params.group)

          # 3rd element
          div(class: 'group-text d-lg-flex flex-lg-column justify-content-lg-between') do
            div do
              h4(class: 'group-title') do
                span(class: "#{'text-transparent' if params.group.try(:name).blank?}") { "#{params.group.try(:name).present? ? params.group.try(:name) : '...'}" }
              end
              p(class: "group-text-content text-book text-gray #{'text-transparent' if params.group.try(:name).blank?}") { params.group.try(:desc).present? ? params.group.try(:desc) : '...' }
            end

            div(class: 'group-info justify-content-start') do

              div(class: "d-flex") do
                div(class: "group-user-count all-users") do
                  i(class: 'ero-users text-gray')
                  div(class: "counter text-primary") {"#{params.group.try(:all_users_count).to_i}"}
                end

                div(class: "group-user-count") do
                  i(class: 'ero-locker text-gray')
                  div(class: "counter text-primary") {"#{params.group.try(:private_users_count).to_i}"}
                end
              end

							if params.user_group.present? && params.user_group.try(:loaded?) && params.try(:user_group).try(:is_public).try(:loaded?)

                value = (PRIVACY_OPTIONS.find{ |option|
                  option[:value] == (params.user_group.is_public ? 'is_public' : 'is_private')
                })[:value]

                if (CurrentUserStore.current_user.present? || false) && value
                  div(class: 'group-privacy d-flex align-items-center') do

                    # EroLink(to: "/profile/#{CurrentUserStore.current_user_id}") do
                    div do
                      img(src: user_photo, class: 'user-avatar')
                    end.on :click do |e|
                      e.prevent_default
                      e.stop_propagation
                      AppRouter.push "/profile/#{CurrentUserStore.current_user_id}"
                    end

                    Select(
                      name: 'privacy',
                      placeholder: 'Ustaw prywatność',
                      className: 'ea-flex-1 silent-select',
                      options: PRIVACY_OPTIONS.to_n,
                      selection: value.to_n
                    ).on :change do |e|
                      set_privacy e.to_n
                    end
                  end.on :click do |e|
                    e.prevent_default
                  end
                end
              end
            end
          end

          if CurrentUserStore.current_user.try(:is_admin)
            div(class: "admin-action-buttons") do
              button(class: 'btn icon-only btn-container text-gray white-border lightest-gray-bg btn-warning', type: "button") do
                i(class: 'ero-pencil')
              end.on(:click) { |e| edit_group params.group, e }

              button(class: 'btn icon-only btn-container text-gray white-border lightest-gray-bg btn-warning', type: "button") do
                i(class: 'ero-trash')
              end.on(:click) { |e| remove_group params.group, e }
            end
          end
        end

      end
    end
  end

  def indicator_count
    puts "indicator_count"
		if CurrentUserStore.current_user.present? && params.user_group.present? && params.user_group.try(:last_visit_at).loaded? && params.user_group.last_visit_at.present?
 			scope = UserGroup.for_group(params.group.try(:id)).created_after(params.user_group.try(:last_visit_at).try(:to_s)).where_user_not(CurrentUserStore.current_user_id)
      if scope.loaded?
        scope.count
      else
        0
      end
    else
      0
    end
  end

  def edit_group group, event=nil
    puts "edit_group"
    if event
      event.prevent_default
      event.stop_propagation
    end
    ModalsService.open_modal('GroupsEditModal', { group: group, size_class: 'modal-lg' })
  end

  def remove_group group, event=nil
    puts "remove_group"
    if event
      event.prevent_default
      event.stop_propagation
    end
    params.on_remove_init.call(group.try(:id))
  end

  def confirm_deletion group, event=nil
    puts "confirm_deletion"
    if event
      event.prevent_default
      event.stop_propagation
    end
    RemoveGroup.run(group_id: group.try(:id)).then do |data|
      `toast.dismiss(); toast.success('Usunęliśmy grupę.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
    end.fail do |err|
      `toast.dismiss(); toast.error('Nie udało się usunąć grupy.')`
    end
  end

  def user_photo
    puts "user_photo"
    if CurrentUserStore.current_user.try(:my_avatar_url)
      CurrentUserStore.current_user.my_avatar_url
    else
      return '/assets/user-blank.png'
    end
  end

  def set_privacy e
    puts "set_privacy"
    proper_value = false
    if e == 'is_private'
      proper_value = false
    elsif e == 'is_public'
      proper_value = true
    end

    UpdateUserGroup.run(user_id: CurrentUserStore.current_user_id, group_id: params.group.try(:id), is_public: proper_value)
    .then do |saved|
      `toast.dismiss(); toast.success('Zmieniono status poprawnie!', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
    end.fail do |error|
      `toast.error('Nie udało się zmienić statusu!')`
    end
  end

  def group_action_button group
    puts "group_action_button"
    if UserGroup.where_user(CurrentUserStore.current_user_id).for_group(group.try(:id)).first
      button(class: "btn icon-only btn-container text-white #{params.blue_bordered_button ? 'primary-border' : 'white-border'} btn-top secondary-bg active", type: "button") do
        i(class: "f-s-18 ero-cross")
      end.on :click do |e|
        e.prevent_default
        leave_group(group)
      end
    else
      button(class: "btn icon-only btn-container text-white #{params.blue_bordered_button ? 'primary-border' : 'white-border'} btn-top #{false ? 'bg-gray-200' : 'secondary-bg'}", type: "button") do
        i(class: "f-s-18 ero-cross")
      end.on :click do |e|
        e.prevent_default
        join_group(group)
      end
    end
  end

  def join_group(group)
    puts "join_group"
    ModalsService.open_modal('GroupsJoinModal', { group: group })
  end

  def leave_group group
    puts "leave_group"
    if group.try(:id).present?
      DeleteUserGroup.run(user_id: CurrentUserStore.current_user_id, group_id: group.try(:id))
      .then do |saved|
        puts "DELETED #{saved}"
        if params.redirect_after_destroy
          puts 'WILL REDIRECT'
          AppRouter.push '/groups'
        end
        `toast.dismiss(); toast.success('Opuściłeś grupę!', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      end.fail do |error|
        puts "ERROR, #{error}"
        `console.error(#{error})`
        `toast.error('Nie udało się opuścić grupy!')`
      end
    end
  end
end