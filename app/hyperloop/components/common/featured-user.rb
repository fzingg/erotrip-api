class FeaturedUser < Hyperloop::Component

  param user: {}
  param is_large: false

  def render
    div(class: "featured-user") do
      EroNavLink(to: "/profile/#{user.id}") do
        img(src: params.user.try(:user).try(:avatar_url) || '/assets/user-blank.png')
      end
    end
  end
end
