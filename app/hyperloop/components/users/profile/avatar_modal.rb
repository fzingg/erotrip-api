class ProfileAvatarModal < Hyperloop::Component
  include BaseModal

  param user: {}
  param photo_id: nil

	state errors: {}
	state avatar_uri: nil
	state blocking: false

  state current_file: {
    result: nil,
    src: nil,
    filename: nil,
    filetype: nil,
    error: nil
  }

  before_mount do
    mutate.current_file["result"] = nil
    mutate.current_file["src"] = nil
    mutate.current_file["filetype"] = nil
    mutate.current_file["filename"] = nil
		mutate.blocking false
  end

  after_mount do
    if CurrentUserStore.current_user.blank?
      ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('ProfileAvatarModal', { size_class: 'modal-lg' }) } })
      close
    else
      if params.photo_id.present?
        GetPhotoData.run(photo_id: params.photo_id).then do |result|

          mutate.current_file["src"] = result[:base64]
          mutate.current_file["filetype"] = result[:extension]
          mutate.current_file["filename"] = result[:filename]
          mutate.current_file["result"] = result[:result]
          mutate.avatar_uri "#{state.current_file['result']};#{state.current_file['filename']}"
        end.fail do |error|
            puts "ERROR #{error}"
        end
      end
    end
  end

  def title
    'Zdjęcie profilowe'
  end

  def render_modal
		span(id: "user-id-#{params.user.id}") do
			BlockUi(tag: "div", blocking: state.blocking) do
				div(class: 'modal-body') do
					div.row do
						div.col.col_xs_12.col_sm_12 do
							div.form_group do
								label {'Ustaw swoje zdjęcie profilowe'}
								DropNCrop(instructions: dropzone_instructions, value: state.current_file.to_n, cropperOptions: {  viewMode: 1, movable: false, zoomable: false, rotatable: false, scalable: false, aspectRatio: 1 }.to_n, canvasHeight: '275px').on :change do |event|
									file_changed Hash.new(event.to_n)
								end
							end
							if (state.errors || {})['photo_uri'].present?
								div.custom_select.is_invalid.d_none
								div.invalid_feedback do
									(state.errors || {})['photo_uri'].to_s;
								end
							end
						end
					end
				end

				div(class: 'modal-footer', style: {justifyContent: 'center', paddingTop: 0}) do
					button(class: 'btn btn-secondary btn-cons mt-3 mb-3', type: "button") do
						'Utwórz'
					end.on :click do
						save_avatar
					end
				end
			end
    end
  end

  def save_avatar
		mutate.blocking true
		SaveUserAvatar.run({
			user_id: params.user.id,
			avatar_uri: state.avatar_uri
		})
    .then do |data|
      mutate.blocking false
      `toast.dismiss(); toast.success('Pomyślnie zaktualizowano zdjęcie profilowe.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      close
    end
		.fail do |e|
			# puts "errory jakies ziom"
			# puts e
      mutate.blocking false
      `toast.error('Przepraszamy! Coś poszło nie tak.')`
      puts "E #{e}"
      if e.class.name.to_s == 'ArgumentError'
        errors = JSON.parse(e.message.gsub('=>', ':'))
        errors.each do |k, v|
          errors[k] = v.join('; ')
        end
        mutate.errors errors
      elsif e.is_a?(Hyperloop::Operation::ValidationException)
        puts "VALID, #{e.errors.message}"
        mutate.errors e.errors.message
      end
      {}
    end
  end

  def file_changed data
    if state.current_file['error'].blank?
      mutate.current_file data
      mutate.avatar_uri "#{state.current_file['result']};#{state.current_file['filename']}"
    else
      `toast.error('Nie udało się załadować obrazka')`
    end
  end

  def dropzone_instructions
    val = [
      React.create_element('div', {key: 'ero-1', className: 'btn btn-secondary mb-2'}) { 'Wybierz' },
      React.create_element('div', {key: 'ero-2', }) {'lub przeciągnij'},
      React.create_element('div', {key: 'ero-3', }) {'tutaj'}
    ]
    val.to_n
  end

end