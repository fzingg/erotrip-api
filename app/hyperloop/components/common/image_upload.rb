class ImageUpload < Hyperloop::Component
	param fileChanged: nil
	param showVerificationPhoto: nil
	param input_id: ""
	param can_upload_photo: nil, nils: true

	state data_uri: ""
	state edit: true

	before_mount do
		state.data_uri ""
	end

	VALID_FORMATS = %w(jpg jpeg png)
	# MAX_SIZE = 5242880 # 5MB
	MAX_SIZE = 10485760 # 10MB

	def render
		# puts "params.can_upload_photo  #{params.can_upload_photo }"
		label(htmlFor: params.input_id, class: "mb-0 ea-flex-1 #{'verification-upload-hover' if params.can_upload_photo}") do
			children.each_with_index do |child, i|
				child.render()
			end

			if params.can_upload_photo
				input(type: "file", id: params.input_id, multiple: false, style: {display: :none}).on(:change) do |e|
					handle_files(e)
				end
			end
		end.on :click do
			if params.can_upload_photo == false
				show_verification_photo
			end
		end
	end

	def handle_files(e)
		`toast.error("Twoja przeglądarka jest zbyt stara...")` && return if `typeof(FileReader) == 'undefined'`
		file = e.target.files[0]
		return unless validate_file(file)
		### continue after validating file meets specifications
		# WTF? where is img#resume-picture?! commenting out
		# image_holder = Element['img#resume-picture']
		# image_holder.empty
		# image_holder.show

		reader = `new FileReader()`
		`reader.onload = function(upload) { #{upload_complete(`upload`)} }`
		`reader.readAsDataURL(#{file.to_n})`
	end

	def validate_file(file)
		if !VALID_FORMATS.include?(`#{file.name}`.split('.').last.downcase)
			# alert("Niepoprawny format zdjęcia. Wgraj w jednym z formatów: #{VALID_FORMATS} ")
			`toast.error("Niepoprawny format zdjęcia. Wgraj w jednym z formatów: jpg jpeg png")`
		elsif `#{file.size}` > MAX_SIZE
			`toast.error("Zdjęcie jest zbyt duże")`
		else
			return true
		end
		nil
	end

	def show_verification_photo
		params.showVerificationPhoto.call(true) if params.showVerificationPhoto
	end

	def upload_complete(upload)
		state.data_uri! `upload.target.result`
		params.fileChanged.call(state.data_uri + ";") if params.fileChanged
	end
end