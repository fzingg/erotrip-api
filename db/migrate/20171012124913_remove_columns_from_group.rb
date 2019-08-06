class RemoveColumnsFromGroup < ActiveRecord::Migration[5.1]
	def change
		remove_column :groups, :photo_url
  end
end
