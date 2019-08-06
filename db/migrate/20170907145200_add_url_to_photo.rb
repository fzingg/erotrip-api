class AddUrlToPhoto < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :url, :string
  end
end
