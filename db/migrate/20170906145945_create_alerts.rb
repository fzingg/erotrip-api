class CreateAlerts < ActiveRecord::Migration[5.1]
  def change
    create_table :alerts do |t|
    	t.string :reason
    	t.text :comment
    	t.boolean :viewed, default: false
    	t.references :resource, polymorphic: true, index: true

    	t.integer :reported_by_id

		t.timestamps
    end

    add_index :alerts, :reported_by_id
  end
end
