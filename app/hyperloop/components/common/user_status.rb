class UserStatus < Hyperloop::Component

  param active_since:   nil
  param inactive_since: nil

  def render
    div(class: "person-status #{calculate_status}")
  end

  def calculate_status
    if params.active_since
      'online'
    elsif params.inactive_since && params.inactive_since > (Time.now - 30.minutes)
      'away'
    else
      'offline'
    end
  end
end
