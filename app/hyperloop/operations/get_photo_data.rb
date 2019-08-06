class GetPhotoData < Hyperloop::ControllerOp; end
class GetPhotoData < Hyperloop::ControllerOp
	param :photo_id, nils: false

	step do
		photo = Photo.find(params.photo_id)
		if photo.present? && acting_user.present? && acting_user.id == photo.user_id
			extension = photo.file_uploader.file.extension
			path = photo.file_uploader.file.path
			filename = photo.file_uploader.file.filename.split('.')[0]
			hash = {
				extension: extension,
				path: path,
				filename: filename ,
				base64: "data:image/#{extension};base64,#{Base64.strict_encode64(File.open(path).read)}",
				result: "data:image/#{extension};base64,#{Base64.strict_encode64(File.open(path).read)}"
			}
		else
			false
		end
	end

	step do |photo|
		photo
	end



end unless RUBY_ENGINE == "opal"