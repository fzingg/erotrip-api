class AddPhotosCountToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :photos_count, :integer, null: false, default: 0
  end
end
