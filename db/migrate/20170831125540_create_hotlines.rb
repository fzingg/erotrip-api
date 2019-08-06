class CreateHotlines < ActiveRecord::Migration[5.1]
  def change
    create_table :hotlines do |t|
      t.text :content
      t.integer :user_id

      t.boolean :anonymous, default: false

      t.decimal :lat, precision: 15, scale: 10
      t.decimal :lon, precision: 15, scale: 10

      t.string :city

      t.timestamps
    end
    add_index :hotlines, :user_id
  end
end
