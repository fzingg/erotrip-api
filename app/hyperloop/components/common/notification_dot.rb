class NotificationDot < Hyperloop::Component

  def render
    if notifications_pending
      div(class: 'button-label notification-pending')
    end
  end

  def notifications_pending
    if CurrentUserStore.current_user
      alerts    = load_scope_counts(Alert.all)
      wtms      = load_scope_counts(CurrentUserStore.current_user.wanted_to_been_met.where_accepted_by_want_to_meet(false))
      peepers   = load_scope_counts(Visit.for_visitee_and_created_after(CurrentUserStore.current_user.id, CurrentUserStore.current_user.last_peepers_visit_at.try(:to_s))) if CurrentUserStore.current_user.last_peepers_visit_at.loaded? && CurrentUserStore.current_user.last_peepers_visit_at.present?
      new_users = load_scope_counts(User.created_after(CurrentUserStore.current_user.last_users_visit_at.try(:to_s))) if CurrentUserStore.current_user.last_users_visit_at.loaded? && CurrentUserStore.current_user.last_users_visit_at.present?
      trips     = load_scope_counts(Trip.created_after(CurrentUserStore.current_user.last_trips_visit_at.try(:to_s))) if CurrentUserStore.current_user.last_trips_visit_at.loaded? && CurrentUserStore.current_user.last_trips_visit_at.present?
    end

    if ((alerts.to_i + wtms.to_i + peepers.to_i + new_users.to_i + trips.to_i ) > 0)
      true
    else
      false
    end
  end

  def load_scope_counts scope
    scope.count if (scope && !scope.loading?)
  end
end
