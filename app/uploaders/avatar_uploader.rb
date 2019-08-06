class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file

	def store_dir
		Rails.root.join('restricted', "#{model.class.to_s.underscore}/#{mounted_as.to_s.chomp("_uploader")}/#{model.id}")
	end

	def cache_dir
		Rails.root.join('tmp', 'restricted', 'cache', "#{model.class.to_s.underscore}/#{mounted_as.to_s.chomp("_uploader")}/#{model.id}")
	end

  # Create different versions of your uploaded files:
  version :rect_160 do
    process resize_to_fill: [160, 160]
  end

  version :blurred do
    process resize_to_fill: [160, 160]
    process blur: "0x25"
  end

  def blur(radius_x_sigma)
    manipulate! do |img|
      img.blur(radius_x_sigma)
      img = yield(img) if block_given?
      img
    end
  end

end
