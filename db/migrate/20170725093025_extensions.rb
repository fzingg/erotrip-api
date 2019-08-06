class Extensions < ActiveRecord::Migration[5.1]
  def change
    enable_extension "pgcrypto"
    enable_extension "unaccent"
    enable_extension "citext"
    enable_extension "hstore"
    enable_extension "postgis"
  end
end
