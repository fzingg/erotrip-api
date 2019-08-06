class ResetPredefinedFilters < ActiveRecord::Migration[5.1]
  def up
    User.update_all(predefined_users: nil, predefined_trips: nil, predefined_hotline: nil)
  end
end
