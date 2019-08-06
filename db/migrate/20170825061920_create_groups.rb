class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.text :desc
      t.string :photo

      t.jsonb :kinds

      t.integer :public_users_count, :null => false, :default => 0
      t.integer :private_users_count, :null => false, :default => 0

      t.timestamps
    end
  end
end
