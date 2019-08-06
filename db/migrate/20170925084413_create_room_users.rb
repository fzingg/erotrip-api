class CreateRoomUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :room_users do |t|
      t.integer :room_id
      t.integer :user_id
      t.integer :unread_counter

      t.timestamps
    end
    add_index :room_users, :room_id
    add_index :room_users, :user_id
    add_index :room_users, :unread_counter
  end
end
