class RemoveUrlColumnsFromPhoto < ActiveRecord::Migration[5.1]
	def change
		remove_column :photos, :url
		remove_column :photos, :thumbnail_url
		remove_column :photos, :blurred_url
  end
end
