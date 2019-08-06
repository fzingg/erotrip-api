class AddConfigurationColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
  	add_column :users, :privacy_settings, :jsonb, default: {
  		show_visits:  true,
  		show_age:     true,
  		show_date:    true,
  		show_groups:  true,
  		show_gallery: true,
  		show_online:  true
  	}

  	add_column :users, :notification_settings, :jsonb, default: {
  		on_message: { email: true, browser: false },
  		on_fit:     { email: true, browser: false },
  		on_like:    { email: true, browser: false },
  		on_guest:   { email: true, browser: false },
  		on_other:   { email: true, browser: false },
  		enable_sound: true
  	}
  end
end
