class Sidebar < Hyperloop::Router::Component

  @last_known_unread_messages_value = nil

  after_mount do
    `$('.sidebar')[0].addEventListener('touchmove', function(e) {e.stopPropagation();})`
  end

  def open_messages_modal
    SidebarStore.set_state false
    if CurrentUserStore.current_user.blank?
      ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static'}) } })
    else
      ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static'})
    end
  end

  def today
    now = Time.now
    Time.new(now.year, now.month, now.day, 0, 0, 0)
  end

  def play_audio
    `$("#sound").html('<audio autoplay="autoplay">  <source src="/notification.mp3" type="audio/mpeg" />  <source src="/notification.ogg" type="audio/ogg" />  <embed hidden="true" autostart="true" loop="false" src="/notification.mp3" /></audio>');`
  end

  def render
    span do
      div(class: "sidebar-backdrop #{'active' if SidebarStore.is_open}").on :click do
        SidebarStore.set_state false
      end
      div(class: "sidebar #{'open' if SidebarStore.is_open}") do
        div(class: 'logo-wrapper') do
          button(class: "btn btn-outline-primary btn-outline-gray btn-menu icon-only with-label", type: "button") do
            i(class: "ero-menu")
            NotificationDot()
          end.on :click do
            SidebarStore.set_state true
          end
          button(class: "btn btn-outline-primary btn-outline-gray btn-close icon-only", type: "button") do
            i(class: "ero-cross rotated-45deg")
          end.on :click do
            SidebarStore.set_state false
          end
          EroNavLink(to: '/users', active_class: 'active', exact: true) do
            img(src: '/assets/logo_obrys_white_small_v2.png', class: 'logo-white-outline', style: { background: 'transparent' })
            img(src: '/assets/logo_obrys_v2.png', class: 'logo-blue-outline')
          end
        end

        span do
          LoggedUser()
        end

        div(class: 'menu') do
          button(class: 'add-trip-button btn btn-secondary') do
            i(class: 'ero-cross-circle')
            span(class: "text-white") {'Dodaj przejazd'}
          end.on(:click) do |e|
            SidebarStore.set_state false
              ModalsService.open_modal('AddTripModal', {size_class: 'modal-lg'})
          end

          ul(class: 'main-submenu') do
            li(class: 'menu-item') do
							EroNavLink(to: '/users', active_class: 'active', exact: true) do

                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: 'ero-users')
                    end
                    div(class: 'label fadeable') {'Osoby'}
                  end
                end.on :click do
                  SidebarStore.set_state false
                end
              end
            end

            li(class: 'menu-item') do
              EroNavLink(to: '/trips', active_class: 'active') do
                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: 'ero-trips')
                    end
                    div(class: 'label fadeable') {'Przejazdy'}
                  end
                end.on :click do
                  SidebarStore.set_state false
                end
              end
            end

            li(class: 'menu-item') do
              EroNavLink(to: '/groups', active_class: 'active') do
                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: 'ero-groups')
                    end
                    div(class: 'label fadeable') {'Grupy'}
                  end
                end.on :click do
                  SidebarStore.set_state false
                end
              end
            end

            li(class: 'menu-item') do
              EroNavLink(to: '/hotline', active_class: 'active') do
                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: 'ero-hotline')
                    end
                    div(class: 'label fadeable') {'Hotline'}
                  end
                end.on :click do
                  SidebarStore.set_state false
                end
              end
            end

            if CurrentUserStore.current_user && CurrentUserStore.current_user.try(:is_admin) == true
              li(class: 'menu-item') do
                EroNavLink(to: '/alerts', active_class: 'active') do

                  div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                    div(class: 'align-items-center d-flex') do
                      div(class: 'icon-wrapper') do
                        i(class: 'ero-alert-circle-outline')
                      end
                      div(class: 'label fadeable') {'Zgłoszenia'}
										end

										CountBadge(scope: Alert.all)
                  end.on :click do
                    SidebarStore.set_state false
                  end

                end
              end
            end
          end

          EroNavLink(to: '/my-trips', auth: true, active_class: 'active') do
            button(class: 'my-trips-button btn btn-primary') do
              i(class: 'ero-my-trips')
              span(class: "text-white") {'Moje przejazdy'}
            end.on :click do
              SidebarStore.set_state false
            end
          end

          ul(class: 'fadeable secondary-submenu') do
            li(class: 'menu-item') do
              a do
                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: 'ero-messages')
                    end
                    div(class: 'label fadeable') {'Wiadomości'}
                  end
                  all_my_room_users = CurrentUserStore.current_user_id.present? ? RoomUser.ransacked(user_id_eq: CurrentUserStore.current_user_id) : []
                  if all_my_room_users.try(:loaded?)
                    if all_my_room_users.select{ |ru| ru.unread_counter.to_i > 0 }.sum(&:unread_counter) > 0
                      if @last_known_unread_messages_value && @last_known_unread_messages_value < all_my_room_users.select{ |ru| ru.unread_counter.to_i > 0 }.sum(&:unread_counter)
                        play_audio
                      end
                      @last_known_unread_messages_value = all_my_room_users.select{ |ru| ru.unread_counter.to_i > 0 }.sum(&:unread_counter)
                      span(class: "badge badge-secondary badge-sidebar mr-2 ml-2") { all_my_room_users.select{ |ru| ru.unread_counter.to_i > 0 }.sum(&:unread_counter).to_s }
                    end
                  end
                  # Hyperloop::Model.load do
                  #   CurrentUserStore.current_user.try(:room_users)
                  # end.then do |data|
                  #   if (sum = (data || []).inject(0) { |sum, p| sum + (p.unread_counter || 0) }) > 0
                  #     span(class: "badge badge-secondary badge-sidebar mr-2 ml-2") { sum.to_s }
                  #   end
                  # end
                end
              end.on 'click' do
                open_messages_modal
              end
            end

            li(class: 'menu-item') do
              EroNavLink(to: '/want-to-meet', auth: true, active_class: 'active') do
                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: 'ero-heart-2')
                    end
    								div(class: 'label fadeable') {'Chcą Cię poznać'}
                  end

									if CurrentUserStore.current_user
										CountBadge(scope: CurrentUserStore.current_user.wanted_to_been_met.where_accepted_by_want_to_meet(false))
									end
                end.on :click do
                  SidebarStore.set_state false
                end
              end
            end

            li(class: 'menu-item') do
              EroNavLink(to: '/peepers', auth: true, active_class: 'active') do
                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: 'ero-eye')
                    end
    								div(class: 'label fadeable') {'Podglądacz'}
                  end

									if CurrentUserStore.current_user && CurrentUserStore.current_user.last_peepers_visit_at.loaded? && CurrentUserStore.current_user.last_peepers_visit_at.present?
										CountBadge(scope: Visit.for_visitee_and_created_after(CurrentUserStore.current_user.id, CurrentUserStore.current_user.try(:last_peepers_visit_at).try(:to_s)))
									end
                end.on :click do
                  SidebarStore.set_state false
                end
              end
            end

            li(class: 'menu-item') do
              EroNavLink(to: '/new-people', auth: true, active_class: 'active') do
                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: 'ero-new-people')
                    end
    								div(class: 'label fadeable') {'Nowe osoby'}
                  end

									if CurrentUserStore.current_user && CurrentUserStore.current_user.last_users_visit_at.loaded? && CurrentUserStore.current_user.last_users_visit_at.present?
                    new_users_scope = User.where_id_not(CurrentUserStore.current_user_id).created_after(CurrentUserStore.current_user.try(:last_users_visit_at).try(:to_s))
                    if CurrentUserStore.current_user.predefined_users
                      new_users_scope = new_users_scope.ransacked(CurrentUserStore.current_user.predefined_users)
                    end
										CountBadge(scope: new_users_scope)
									end
                end.on :click do
                  SidebarStore.set_state false
                end
              end
            end

            li(class: 'menu-item') do
              EroNavLink(to: '/new-trips', auth: true, active_class: 'active') do
                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: 'ero-new-trips')
                    end
    								div(class: 'label fadeable') {'Nowe przejazdy'}
                  end

									if CurrentUserStore.current_user && CurrentUserStore.current_user.last_trips_visit_at.loaded? && CurrentUserStore.current_user.last_trips_visit_at.present?
										CountBadge(scope: Trip.not_by_user(CurrentUserStore.current_user_id).created_after(CurrentUserStore.current_user.try(:last_trips_visit_at).try(:to_s)).arrival_after((today - 1.month).to_s))
									end
                end.on :click do
                  SidebarStore.set_state false
                end
              end
            end

            li(class: 'menu-item') do
              EroNavLink(to: '/unlocks', auth: true, active_class: 'active') do
                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: '')
                    end
    								div(class: 'label fadeable') {'Odblokowania'}
									end

									if CurrentUserStore.current_user_id.present?
										CountBadge(scope: AccessPermission.where_owner(CurrentUserStore.current_user_id).unanswered)
									end
                end.on :click do
                  SidebarStore.set_state false
                end
              end
            end

            li(class: 'menu-item') do
              EroLink(to: '/anonymous', auth: true, disabled: true) do
                div(class: 'justify-content-between align-items-center d-flex ea-flex-1') do
                  div(class: 'align-items-center d-flex') do
                    div(class: 'icon-wrapper') do
                      i(class: 'ero-locker')
                    end
                    div(class: 'label fadeable') {'Tryb anonimowy'}
                  end
                  if CurrentUserStore.current_user.try(:is_private)
                    span(class: "badge badge-anonymous mr-2 ml-2") {''}
                  end
                end.on :click do
                  SidebarStore.set_state false
                end
              end
						end.on(:click) do |e|
							e.prevent_default
							e.stop_propagation
              if CurrentUserStore.current_user_id.blank?
                ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('AnonymousModal', { }) } })
              else
                ModalsService.open_modal('AnonymousModal', { })
              end
						end
          end
        end
      end
    end
  end
end
