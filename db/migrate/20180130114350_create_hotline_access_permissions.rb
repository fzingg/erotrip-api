class CreateHotlineAccessPermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :hotline_access_permissions do |t|
      t.integer :hotline_id
      t.integer :owner_id
      t.integer :permitted_id
      t.boolean :is_permitted

      t.timestamps
    end
    add_index :hotline_access_permissions, :hotline_id
    add_index :hotline_access_permissions, :owner_id
    add_index :hotline_access_permissions, :permitted_id
    add_index :hotline_access_permissions, :is_permitted
  end
end
