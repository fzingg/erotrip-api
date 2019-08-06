class ChangeExistingDestinationsInTrip < ActiveRecord::Migration[5.1]
  def up
    Trip.where('destinations is not null').each do |t|
      t.destinations = { data: t.destinations }
      t.update_column(:destinations, t.destinations)
    end
  end

  def down
    Trip.where('destinations is not null').each do |t|
      t.destinations = t.destinations['data']
      t.update_column(:destinations, t.destinations)
    end
  end
end
