class AddThumbnailUrlToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :thumbnail_url, :string
  end
end
