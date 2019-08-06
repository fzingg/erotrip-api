class ChangeDefaultNotificationSettingsToTrue < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :notification_settings, :jsonb, default: {
      on_message: { email: true, browser: true },
      on_fit:     { email: true, browser: true },
      on_like:    { email: true, browser: true },
      on_guest:   { email: true, browser: true },
      on_other:   { email: true, browser: true },
      enable_sound: true
    }
  end
end
