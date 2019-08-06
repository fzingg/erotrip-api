class AddIsAnononymousToTrip < ActiveRecord::Migration[5.1]
  def change
    add_column :trips, :is_anonymous, :boolean
  end
end
