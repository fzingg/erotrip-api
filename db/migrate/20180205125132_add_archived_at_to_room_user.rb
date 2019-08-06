class AddArchivedAtToRoomUser < ActiveRecord::Migration[5.1]
  def change
    add_column :room_users, :archived_at, :datetime
    add_index :room_users, :archived_at
  end
end
