class CreateTrips < ActiveRecord::Migration[5.1]
  def change
    create_table :trips do |t|
    	t.references :user, index: true

    	t.datetime :arrival_time

    	t.jsonb :destinations, default: [], nil: false, index: true

    	t.text :description

    	t.timestamps
    end
  end
end
