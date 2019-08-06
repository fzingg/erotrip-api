class GroupPhotoUploader < CarrierWave::Uploader::Base

		# Include RMagick or MiniMagick support:
		# include CarrierWave::RMagick
		include CarrierWave::MiniMagick

		# Choose what kind of storage to use for this uploader:
		storage :file
		# storage :fog

		# Override the directory where uploaded files will be stored.
		# This is a sensible default for uploaders that are meant to be mounted:

		# Erotrip
		# Chomp _uploader from mount name to persist nice urls like /avatar/1/nice.jpg instead of /avatar_uploader/1/ugly.jpg
		def store_dir
			Rails.root.join('public', 'uploads', "#{model.class.to_s.underscore}/#{mounted_as.to_s.chomp("_uploader")}/#{model.id}")
		end

		# Provide a default URL as a default if there hasn't been a file uploaded:
		# def default_url(*args)
		#   # For Rails 3.1+ asset pipeline compatibility:
		#   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
		#
		#   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
		# end

		# Process files as they are uploaded:
		# process scale: [200, 300]
		#
		# def scale(width, height)
		#   # do something
		# end

		# Create different versions of your uploaded files:
		# groups
		version :rect_160 do
			process resize_to_fill: [160, 160]
		end

		# gallery thumbnail
		version :rect_150 do
			process resize_to_fill: [150, 150]
		end

		# blurred gallery thumbnail
		# version :blurred do
		# 	process resize_to_fill: [150, 150]
		# 	process blur: "0x7"
		# end

		def blur(radius_x_sigma)
			manipulate! do |img|
				img.blur(radius_x_sigma)
				img = yield(img) if block_given?
				img
			end
		end

		# Add a white list of extensions which are allowed to be uploaded.
		# For images you might use something like this:
		# def extension_whitelist
		#   %w(jpg jpeg gif png)
		# end

		# Override the filename of the uploaded files:
		# Avoid using model.id or version_name here, see uploader/store.rb for details.
		# def filename
		#   "something.jpg" if original_filename
		# end

	end
