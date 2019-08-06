class Header < Hyperloop::Router::Component

  before_receive_props do |new_props|
    if React::IsomorphicHelpers.on_opal_client?
      `window.scrollTo(0,0)`
    end
  end

  def render
    div(class: 'd-none d-md-flex row') do
      if RUBY_ENGINE == 'opal'
        div(class: "col-12 col-xl-9 ml-xl-auto #{'d-none' if url_matches_profile(location.pathname)}") do

          div(class: 'featured streach-me') do
            div(class: 'patch ea-flex-0')
            User.ransacked( avatar_uploader_present: true, is_private_eq: false, sorts: 'created_at desc').limit(10).each do |user|
              EroNavLink(to: "/profile/#{user.id}") do
                img(src: user.avatar_url || '/assets/user-blank.png')
              end
            end
          end

        # end.while_loading do
        #   mocked_featured
        end
      end
    end
  end

  # def mocked_featured
  #   div(class: 'featured streach-me') do
  #     div(class: 'patch ea-flex-0')
  #     10.times do
  #       a(class: 'mocked-featured-user')
  #     end
  #   end
  # end

  def url_matches_profile pathname
    (pathname.to_s).include? "profile/"
  end
end