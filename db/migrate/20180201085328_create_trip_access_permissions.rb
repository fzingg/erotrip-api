class CreateTripAccessPermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :trip_access_permissions do |t|
      t.integer :trip_id
      t.integer :owner_id
      t.integer :permitted_id
      t.integer :is_permitted

      t.timestamps
    end
    add_index :trip_access_permissions, :trip_id
    add_index :trip_access_permissions, :owner_id
    add_index :trip_access_permissions, :permitted_id
    add_index :trip_access_permissions, :is_permitted
  end
end
