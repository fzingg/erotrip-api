class CreateVisits < ActiveRecord::Migration[5.1]
  def change
		create_table :visits do |t|
			t.integer :visitee_id
			t.integer :visitor_id
			t.timestamps
    end
  end
end
