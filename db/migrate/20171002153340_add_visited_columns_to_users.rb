class AddVisitedColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :last_users_visit_at, :datetime
    add_column :users, :last_peepers_visit_at, :datetime
		add_column :users, :last_trips_visit_at, :datetime

		add_index :users, :last_users_visit_at
    add_index :users, :last_peepers_visit_at
		add_index :users, :last_trips_visit_at
	end


end
