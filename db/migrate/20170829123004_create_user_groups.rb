class CreateUserGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :user_groups do |t|
      t.integer :user_id
      t.integer :group_id
      t.boolean :public

      t.timestamps
    end
    add_index :user_groups, :user_id
    add_index :user_groups, :group_id
    add_index :user_groups, :public
  end
end
