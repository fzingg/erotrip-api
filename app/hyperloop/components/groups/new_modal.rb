class GroupsNewModal < Hyperloop::Component
	include BaseModal

	param group: nil
	param current_file: nil

  state group: {}
  state errors: {}

  state current_file: {
    result: nil,
    src: nil,
    filename: nil,
    filetype: nil,
    error: nil
  }

	before_mount do
		if params.group.present?
			mutate.group params.group
		else
			mutate.group({name: '', desc: ''})
		end

		if params.current_file.present?
			mutate.current_file params.current_file
		end
  end

  def title
    'Utwórz nową grupę'
  end

  def render_modal
    span do
      div(class: 'modal-body') do
        div(class: 'row') do
          div(class: 'col-12 col-md-6') do

            FormGroup(label: 'Nazwa', error: state.errors['name']) do
              input(placeholder: "Nazwa", name: 'name', value: state.group['name'],class: "form-control").on :change do |e|
                mutate.group['name'] = e.target.value
                mutate.errors['name'] = nil
							end
							div(class: 'text-right mt-1') do
                span(class: "text-regular #{'text-danger' if (state.group['name'] || '').size >= 40}") { "#{40 - (state.group['name'] || '').size}" }
              end
            end

            FormGroup(label: 'Opis', error: state.errors['desc']) do
              textarea(placeholder: "Opis", name: 'desc', value: state.group['desc'], class: "form-control", maxLength: 140).on :change do |e|
                mutate.group['desc'] = e.target.value
                mutate.errors['desc'] = nil
              end
              div(class: 'text-right mt-1') do
                span(class: "text-regular #{'text-danger' if (state.group['desc'] || '').size >= 140}") { "#{140 - (state.group['desc'] || '').size}" }
              end
            end

            # FormGroup(label: 'Dla rodzajów kont', error: state.errors['kinds']) do
            #   MultiSelect(placeholder: "Rodzaj", name: 'kinds', class: "form-control", selection: state.group['kinds'] || [], options: Commons.account_kinds, scrollMenuIntoView: false).on :change do |e|
            #     mutate.group['kinds'] = Array.new(e.to_n)
            #     mutate.errors['kinds'] = nil
            #   end
            # end

          end
          div(class: 'col-12 col-md-6') do
            div.form_group do
              label {'Zdjęcie'}
              DropNCrop(instructions: dropzone_instructions, value: state.current_file.to_n, cropperOptions: { viewMode: 1, movable: false, zoomable: false, rotatable: false, scalable: false, aspectRatio: 1 }.to_n, canvasHeight: '275px').on :change do |event|
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
        button(class: 'btn btn-secondary btn-cons mt-3 mb-0', type: "button") do
          'Utwórz'
        end.on :click do
          auth_and_save_group
        end
      end
    end
	end

	def auth_and_save_group
		puts CurrentUserStore.current_user.blank?
		if CurrentUserStore.current_user.blank?
			ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('GroupsNewModal', { group: state.group, current_file: state.current_file, size_class: 'modal-lg' }) } })
			close
		else
			save_group
		end
	end

  def save_group
    mutate.blocking true
    SaveGroup.run(state.group)
    .then do |data|
      mutate.blocking false
      `toast.dismiss(); toast.success('Dodaliśmy nową grupę.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      close
    end
    .fail do |e|
      mutate.blocking false
      `toast.error('Nie udało się zarejestrować.')`
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
    if state.current_file['error'].blank?
      mutate.current_file data
      mutate.group['photo_uri'] = "#{state.current_file['result']};#{state.current_file['filename']}"
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