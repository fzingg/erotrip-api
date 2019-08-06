class CreateWantToMeets < ActiveRecord::Migration[5.1]
  def change
    create_table :want_to_meets do |t|
      t.integer :user_id
      t.integer :want_to_meet_id
      t.timestamps
    end
    add_index :want_to_meets, :user_id
    add_index :want_to_meets, :want_to_meet_id
  end
end
