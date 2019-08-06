class UserDescriptor < Hyperloop::Component

  param user: {}
  param show_verification: false
  param show_two_lined: false
  param show_status: false
  param show_city: false, nils: true
  param show_last_sign_in: false, nils: true
  param mode: '', nils: true

  after_mount do
    # puts "USER INACTIVE SINCE: #{params.user.try(:inactive_since)}"
  end

  def render
    div(class: "user-descriptor #{'hotline-user-descriptor' if params.mode == 'hotline'}") do

      div(class: 'user-descriptor-inner-wrapper') do
        # STATUS
        div(class: "person-status #{calculate_status} #{'is-hidden' if params.user.blank? || !params.user.try(:loaded?)}") if params.show_status

        # TEXT
        if is_couple? && !params.show_two_lined
          div(class: 'couple') do
            span(class: 'first-person') do
              span(class: 'first-person-name') { params.user.try(:name) }
              span(class: 'first-person-age') { get_inline_age(params.user.try(:birth_year)) } if (params.user.try(:privacy_settings).try(:[], 'show_age') == true && params.mode != 'messenger-list')
            end
            if params.mode == 'messenger-list'
              span {", "}
            else
              span { " " }
            end
            span(class: 'second-person') do
              span(class: 'second-person-name') { params.user.try(:name_second_person) }
              span(class: 'second-person-age') { get_inline_age(params.user.try(:birth_year_second_person)) } if (params.user.try(:privacy_settings).try(:[], 'show_age') == true && params.mode != 'messenger-list')
            end
          end

        elsif is_couple? && params.show_two_lined
          div(class: 'couple') do
            span(class: 'couple-first-person') do
              span(class: 'couple-first-person-name') { params.user.try(:name) }
              get_age(params.user.try(:birth_year)) if params.user.try(:privacy_settings).try(:[], 'show_age') == true
            end
            span(class: 'couple-second-person mb-0') do
              span(class: 'couple-second-person-name') { params.user.try(:name_second_person) }
              get_age(params.user.try(:birth_year_second_person)) if params.user.try(:privacy_settings).try(:[], 'show_age') == true
            end
          end

        else
          span(class: 'first-person') { params.user.try(:name) }
          get_age(params.user.try(:birth_year)) if (params.user.try(:privacy_settings).try(:[], 'show_age') == true && params.mode != 'messenger-list')
        end

        # VERIFICATION
        if params.user && !!params.show_verification && !!params.user.try(:is_verified)
          i(class: 'ero-checkmark icon full-bg ml-2')
        end
      end

      div do
        # if !!params.show_last_sign_in
        #   span(class: "user-descriptor-last-seen") { params.user.try(:last_sign_in) if (params.user.try(:privacy_settings).is_a?(Hash) && params.user.try(:privacy_settings).try(:[], 'show_date') == true) || owned_by_user }
        # end
        if !!params.show_city
          span(class: 'user-descriptor-city') { params.user.try(:city) }
        end
      end

    end
  end

  def is_couple?
    ['couple', 'women_couple', 'men_couple'].include? params.user.try(:kind)
  end

  def get_age birth_year
    if (birth_year.try(:to_i).try(:>, 0) && params.user.try(:privacy_settings).try(:[], 'show_age') == true)
      span(class: 'age') do
        div(class: 'coma') {','}
        span(class: '') {(Time.now.year - birth_year.to_i).to_s}
      end
    end
  end

  def get_inline_age birth_year
    if (birth_year.try(:to_i).try(:>, 0) && params.user.try(:privacy_settings).try(:[], 'show_age') == true)
      span {( ", " + (Time.now.year - birth_year.to_i).to_s)}
    end
  end

  def calculate_status
    if params.user.try(:privacy_settings).present? || params.user.try(:active_since).present? || params.user.try(:inactive_since).present?
      if params.user.try(:privacy_settings).try(:[], 'show_online') == false
        'offline'
      else
        if params.user.try(:active_since).present?
          'online'
        elsif params.user.try(:inactive_since).present? && Time.parse(params.user.try(:inactive_since).to_s).try(:to_i).try(:>, (Time.now - 30.minutes).try(:to_i))
          'away'
        else
          'offline'
        end
      end
    else
      'hidden'
    end
  end

  def owned_by_user
    if (CurrentUserStore.current_user && (CurrentUserStore.current_user_id == params.user.try(:id) || CurrentUserStore.current_user.try(:is_admin)))
      true
    else
      false
    end
  end

end
