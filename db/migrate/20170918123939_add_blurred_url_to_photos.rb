class AddBlurredUrlToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :blurred_url, :string
  end
end
