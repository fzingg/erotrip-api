class CreateRooms < ActiveRecord::Migration[5.1]
  def change
    create_table :rooms do |t|
      t.integer :context_id
      t.string :context_type
      t.integer :last_message_id

      t.timestamps
    end
    add_index :rooms, [:context_id, :context_type]
    add_index :rooms, :last_message_id
  end
end
