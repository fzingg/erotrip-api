class ProfilePhotoModal < Hyperloop::Component
  include BaseModal

  param user: {}
	state errors: {}
	state photo_uri: nil


  after_mount do
    if CurrentUserStore.current_user.blank?
      ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('ProfilePhotoModal', { size_class: 'modal-lg' }) } })
      close
		end
  end

  def title
    'Dodaj zdjęcie'
  end

  def render_modal
    span(id: "user-id-#{params.user.id}") do
      div(class: 'modal-body') do
        div.row do
          div.col.col_xs_12.col_sm_12 do
            div.form_group do
              label {'Dodaj nowe zdjęcie do swojej galerii.'}
							ImageUpload(fileChanged: proc { |photo_uri| file_changed(photo_uri) })
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
          save_photo
        end
      end
    end
  end

  def save_photo
		mutate.blocking true
		SaveUserPhoto.run({
			user_id: params.user.id,
			photo_uri: state.photo_uri
		})
    .then do |data|
      mutate.blocking false
      `toast.dismiss(); toast.success('Nowe zdjęcie zostało dodane.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      close
    end
		.fail do |e|
      mutate.blocking false
      `toast.error('PrzepraszamyP! Coś poszło nie tak.')`
      if e.class.name.to_s == 'ArgumentError'
        errors = JSON.parse(e.message.gsub('=>', ':'))
        errors.each do |k, v|
          errors[k] = v.join('; ')
        end
        mutate.errors errors
      elsif e.is_a?(Hyperloop::Operation::ValidationException)
        mutate.errors e.errors.message
      end
      {}
    end
  end

	def file_changed data
		mutate.photo_uri data;
  end
end