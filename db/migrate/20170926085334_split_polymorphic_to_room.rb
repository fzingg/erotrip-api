class SplitPolymorphicToRoom < ActiveRecord::Migration[5.1]
  def change
    add_column :rooms, :trip_id, :integer
    add_index :rooms, :trip_id

    add_column :rooms, :hotline_id, :integer
    add_index :rooms, :hotline_id

    add_column :rooms, :room_id, :integer
    add_index :rooms, :room_id

    add_column :rooms, :owner_id, :integer
    add_index :rooms, :owner_id

    remove_index :rooms, [:context_id, :context_type]
    remove_column :rooms, :context_id
    remove_column :rooms, :context_type

    Room.destroy_all
  end
end
