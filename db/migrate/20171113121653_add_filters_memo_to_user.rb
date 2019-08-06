class AddFiltersMemoToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :predefined_users, :jsonb
    add_column :users, :predefined_trips, :jsonb
    add_column :users, :predefined_hotline, :jsonb
  end
end
