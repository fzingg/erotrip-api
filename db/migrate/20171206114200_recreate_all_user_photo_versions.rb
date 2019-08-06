class RecreateAllUserPhotoVersions < ActiveRecord::Migration[5.1]
  def up
    User.where('verification_photo_uploader is not NULL').all.each_with_index do |u, i|
      begin
        puts "RECREATING #{i} verification photo"
        u.verification_photo_uploader.recreate_versions!
      rescue Exception => e
        puts "ERROR in #{i} verification photo -> #{e.message}"
      end
    end
    Photo.where('file_uploader is not NULL').all.each_with_index do |p, i|
      begin
        puts "RECREATING #{i} gallery photo"
        p.file_uploader.recreate_versions!
      rescue Exception => e
        puts "ERROR in #{i} gallery photo -> #{e.message}"
      end
    end
  end

  def down
  end
end
