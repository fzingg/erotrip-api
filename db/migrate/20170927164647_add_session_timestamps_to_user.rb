class AddSessionTimestampsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :active_since, :datetime
    add_column :users, :inactive_since, :datetime
  end
end
