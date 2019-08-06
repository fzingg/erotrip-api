class GroupsEditModal < Hyperloop::Component
  include BaseModal

	state group: {}
	state group_record: nil
	state errors: {}
	state update_photo: false

  state current_file: {
    result: nil,
    src: nil,
    filename: nil,
    filetype: nil,
    error: nil
  }

  after_mount do
    if CurrentUserStore.current_user.blank? || !CurrentUserStore.current_user.is_admin?
      ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('GroupsNewModal', { size_class: 'modal-lg' }) } })
      close
    else
			Group.find(params.attributes[:group].id).load(:id, :name, :desc).then do |data|
				group = Group.find(params.attributes[:group].id)
				mutate.group_record group
				mutate.group({
					id: group.id,
					desc: group.desc,
					name: group.name,
					photo_uri: nil
				})
			end
    end
	end

	# Hotline.find(params.attributes[:hotline].id).load(:id, :content, :user_id, :is_anonymous, :lat, :lon, :city).then do |data|
	# 	hot = Hotline.find(params.attributes[:hotline].id)
	# 	mutate.hotline({
	# 		id: hot.id,
	# 		content: hot.content,
	# 		user_id: hot.user_id,
	# 		is_anonymous: hot.is_anonymous,
	# 		lat: hot.lat,
	# 		lon: hot.lon,
	# 		city: hot.city
	# 	})
	# end

  def title
    'Edytuj grupę'
  end

	def render_modal
    span do
      div(class: 'modal-body') do
        div(class: 'row') do
          div(class: 'col-12 col-md-6') do

            FormGroup(label: 'Nazwa', error: state.errors['name']) do
              input(placeholder: "Nazwa", name: 'name', value: state.group['name'], class: "form-control").on :change do |e|
                mutate.group['name'] = e.target.value
                mutate.errors['name'] = nil
              end
            end

            FormGroup(label: 'Opis', error: state.errors['desc']) do
              textarea(placeholder: "Opis", name: 'desc', value: state.group['desc'] ,class: "form-control", maxLength: 140).on :change do |e|
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
							div(class: "group-edit-modal-photo-container") do
								if state.update_photo
									DropNCrop(instructions: dropzone_instructions, value: state.current_file.to_n, cropperOptions: { viewMode: 1, movable: false, zoomable: false, rotatable: false, scalable: false, aspectRatio: 1 }.to_n, canvasHeight: '275px').on :change do |event|
										file_changed Hash.new(event.to_n)
									end
								else
									div(class: "current-photo") do
										if state.group_record
											img(class: "img-fit", src: state.group_record.try(:photo_url) || '/assets/user-blank.png')
										else
											img(class: "img-fit", src: '/assets/user-blank.png')
										end
									end
								end
								button(class: "btn icon-only btn-container text-white secondary-bg active", type: "button") do
									i(class: "f-s-18 #{if state.update_photo then 'ero-cross' else 'ero-pencil' end}")
								end.on :click do |e|
									e.prevent_default
									mutate.update_photo !state.update_photo
								end
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
          'Zapisz'
        end.on :click do
          save_group
        end
      end
    end
  end

  def save_group
		mutate.blocking true

		group = state.group
		if !state.update_photo
			group[:photo_uri] = nil
		end
    SaveGroup.run(group)
    .then do |data|
      mutate.blocking false
      `toast.dismiss(); toast.success('Grupa zaktualizowana.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      close
    end
    .fail do |e|
			mutate.blocking false
			puts e
			`console.log(#{e})`
      `toast.error('Coś poszło nie tak.')`
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