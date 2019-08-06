class ChangeDefaultNotificationSettings < ActiveRecord::Migration[5.1]
	def change
		change_column :users, :notification_settings, :jsonb, default: {
  		on_message: { email: false, browser: false },
  		on_fit:     { email: false, browser: false },
  		on_like:    { email: false, browser: false },
  		on_guest:   { email: false, browser: false },
  		on_other:   { email: false, browser: false },
  		enable_sound: true
  	}
  end
end
