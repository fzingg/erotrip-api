class FooterNumberDiv < Hyperloop::Component
	param :scope

	def render
			div(class: 'number') do
				if params.scope && !params.scope.loading? && params.scope.count > 0
					params.scope.count.to_s
				elsif params.scope && params.scope.loading?
					'...'
        else
          '0'
				end
			end
	end
end

class Footer < Hyperloop::Router::Component

  def render
    div(class: 'row') do
      div(class: "col-12 col-xl-9 ml-xl-auto") do

        div(class: "#{'d-none' if url_matches_profile(location.pathname)}") do
          div(class: 'featured featured-large streach-me mt-5') do
            div(class: 'patch ea-flex-0')
            User.ransacked( avatar_uploader_present: true, sorts: 'created_at desc', is_private_eq: false).limit(7).each do |user|
              EroNavLink(to: "/profile/#{user.id}") do
                img(src: user.avatar_url || '/assets/user-blank.png')
              end
            end
          end
        # end.while_loading do
        #   mocked_featured
        end

        div(class: "footer streach-me d-none d-xl-flex #{'mt-5' if url_matches_profile(location.pathname)}") do
          user_scope          = User
          user_verified_scope = User.ransacked(is_verified_eq: true)
          user_private_scope  = User.ransacked(is_private_eq: true)
          user_online_scope   = User.ransacked(active_since_not_null:true)
          trips_scope         = Trip

          div(class: 'patch')
          div(class: 'row no-gutters') do
            div(class: 'col') do
              div(class: 'footer-stats-wrapper') do
                div(class: 'footer-stats') do
                  div.name {'Osób'}
									FooterNumberDiv(scope: user_scope)
                end
              end
            end
            div(class: 'col') do
              div(class: 'footer-stats-wrapper') do
                div(class: 'footer-stats') do
                  div.name {'Zweryfikowanych'}
									FooterNumberDiv(scope: user_verified_scope)
                end
              end
            end
            div(class: 'col') do
              div(class: 'footer-stats-wrapper') do
                div(class: 'footer-stats') do
                  div.name {'Online'}
									FooterNumberDiv(scope: user_online_scope)
                end
              end
            end
            div(class: 'col') do
              div(class: 'footer-stats-wrapper') do
                div(class: 'footer-stats') do
                  div.name {'Ukrytych'}
									FooterNumberDiv(scope: user_private_scope)
                end
              end
            end
            div(class: 'col') do
              div(class: 'footer-stats-wrapper') do
                div(class: 'footer-stats') do
                  div.name {'Przejazdów'}
									FooterNumberDiv(scope: trips_scope)
                end
              end
            end
          end
        end

        div(class: 'footer-info d-xl-none') do
          div(class: 'footer-info-text p-5') do
            div(class: 'text-book text-center text-gray-light f-s-11') {'Copyright 2017 © Erotrip.pl Wszystkie prawa zastrzeżone'}
            div(class: 'ea-flex ea-just-center') do
              button(class: 'btn btn-link text-gray', type: 'button', href: "mailto:kontakt@erotrip.pl") {'Kontakt'}
              # button(class: 'btn btn-link text-gray', type: 'button') {'Regulamin'}
            end
          end
        end
      end
    end
  end

  # def mocked_featured
  #   div(class: 'featured featured-large streach-me') do
  #     div(class: 'patch ea-flex-0')
  #     7.times do
  #       a(class: 'mocked-featured-user')
  #     end
  #   end
  # end

  def url_matches_profile pathname
    (pathname.to_s).include? "profile/"
  end
end