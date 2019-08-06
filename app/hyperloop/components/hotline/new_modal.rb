class HotlineNewModal < Hyperloop::Component
	include BaseModal

  @hotline_content = ''

	param hotline: nil

  state hotline: { city: '', is_anonymous: false }
  state errors: {}
  state disable_buttons: false

  state current_file: {
    result: nil,
    src: nil,
    filename: nil,
    filetype: nil,
    error: nil
  }

  before_mount do
    mutate.disable_buttons false
		if params.hotline.present?
      mutate.hotline params.hotline
      # here i ensure that @hotline_content persisted after callback
			@hotline_content = params.hotline['content']
		else
			mutate.hotline({ city: '', is_anonymous: false })
			if CurrentUserStore.current_user.present?
				mutate.hotline['city'] = CurrentUserStore.current_user.city
			end
		end
  end

  def title
    'Dodaj ogłoszenie hotline'
  end

  def city_selected(val)
    mutate.disable_buttons false

    if React::IsomorphicHelpers.on_opal_client?
      Native(`window`).GeocodeByAddress(val)
      .then do |results|
          result = Hash.new(Array.new(results.to_n)[0])
            mutate.hotline['city'] = result['address_components'][0]['short_name']

        Native(`window`).GetLatLng(result.to_n)
        .then do |lon_lat_results|
          lon_lat = Hash.new(lon_lat_results)
          process_geo_data(lon_lat)
        end
      end
    end
  end

  def process_geo_data(lon_lat)
    mutate.hotline['lon'] = lon_lat['lng']
    mutate.hotline['lat'] = lon_lat['lat']
  end

  def city_changed(val)
    mutate.hotline['city'] = val
    if val.size > 0
      mutate.disable_buttons true
    else
      mutate.disable_buttons false
    end
  end

  def render_modal
    span do
      div(class: 'modal-body add-hotline-modal') do
        div(class: 'row') do

          div(class: 'col-3 col-md-3') do
            img(class: 'img-fit br-10', src: CurrentUserStore.current_user.try(:avatar_url).present? ? "#{CurrentUserStore.current_user.try(:avatar_url)}&version=#{state.hotline['is_anonymous'] ? 'blurred' : 'normal'}" : '/assets/user-blank.png')
          end

          div(class: 'add-hotline-textarea-wrapper col-9 col-md-9') do
            FormGroup(label: 'Opis', error: state.errors['content'], classNames: 'mb-0') do

              Textarea(
                placeholder: "Opis",
                name: 'content',
                class_name: "add-hotline-textarea",
                value: state.hotline['content'],
                onChange: proc{ |val| @hotline_content = val }
              )

            end

            # span(class: "add-hotline-counter text-regular #{'text-danger' if (state.hotline['content'] || '').size >= 140}") { "#{140 - (state.hotline['content'] || '').size}" }
          end
        end

        div(class: 'row mt-1') do
          div(class: 'col-12 col-md-9 ml-md-auto') do
            label(class: 'form-check-label big-round-label') do
              p(class: "mb-0 mr-2") {'Dodaj anonimowo'}
              input.form_check_input(type: "checkbox", checked: !!state.hotline["is_anonymous"]).on :change do |e|
                mutate.hotline['is_anonymous'] = e.target.checked
              end
              span
            end

            div(class: "add-hotline-modal-text text-gray-light") do
              p(class: "mb-0") {"Będziesz otrzymywał prywatne wiadomości ale Twój profil nie będzie widoczny. Odblokujesz go wybranym osobom w dowolnym momencie."}
              # p(class: "mb-0") {"Odblokujesz go wybranym osobom w dowolnym momencie."}
            end


            div(class: 'd-flex align-items-start justify-content-start mt-3') do
              span(class: '', style: { paddingTop: '10px' } ) { 'Miejscowość' }


              FormGroup(label: 'Opis', error: state.errors['city'], classNames: 'mb-0 add-hotline-modal-google-places-wrapper') do
                GooglePlacesAutocomplete(
                  inputProps: { value: state.hotline['city'], onChange: proc{ |e| city_changed(e)}, placeholder: ''}.to_n,
                  options: Commons::MAP_OPTIONS.to_n,
                  googleLogo: false,
                  defaultSuggestions: [
                    { suggestion: "Warszawa", placeId: 0, active: false, index: 0, formattedSuggestion: nil },
                    { suggestion: "Kraków", placeId: 1, active: false, index: 1, formattedSuggestion: nil },
                    { suggestion: "Łódź", placeId: 2, active: false, index: 2, formattedSuggestion: nil },
                    { suggestion: "Wrocław", placeId: 3, active: false, index: 3, formattedSuggestion: nil },
                    { suggestion: "Poznań", placeId: 4, active: false, index: 4, formattedSuggestion: nil }
                  ].to_n,
                  # debounce: 400,
                  classNames: Commons::CSS_CLASSES.to_n,
                  onSelect: proc{ |e| city_selected(e)}
                )
              end
            end

          end
        end
      end

      div(class: 'modal-footer mt-2') do
        button(
          class: 'btn btn-secondary btn-cons',
          type: "button",
          disabled: state.disable_buttons
        ) do
          'Dodaj Hotline'
        end.on :click do
          auth_and_save_hotline
        end

        button(
          class: 'btn btn-outline-primary btn-cons btn-outline-cancel text-gray',
          type: "button",
          disabled: state.disable_buttons
        ) do
          'Anuluj'
        end.on :click do
          close
        end
      end
    end
  end

	def auth_and_save_hotline
		if !CurrentUserStore.current_user
      validate_hotline_and_prompt
		else
			save_hotline
		end
	end

  def validate_hotline_and_prompt
    mutate.blocking true
    mutate.hotline['content'] = @hotline_content
    ValidateHotline.run(state.hotline)
    .then do |data|
      mutate.blocking false
      if !CurrentUserStore.current_user
        ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('HotlineNewModal', { hotline: state.hotline, size_class: 'modal-lg' }) } })
        close
      else
        save_hotline
      end
    end
    .fail do |e|
      mutate.blocking false
      if e.is_a?(Exception) && e.message
        errors = JSON.parse(e.message.gsub('=>', ':'))
        puts "ERRORS #{errors}"
        errors.each do |k, v|
          errors[k] = v.join('; ') if v.is_a?(Array)
          end
          puts "ERRORS, #{errors}"
        mutate.errors errors
      end
      {}
    end
  end

  def save_hotline
    mutate.hotline['content'] = @hotline_content
    mutate.hotline['acting_user'] = CurrentUserStore.current_user
    mutate.blocking true
    SaveHotline.run(state.hotline)
    .then do |data|
      mutate.blocking false
      `toast.dismiss(); toast.success('Dodaliśmy hotline.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      close
    end
    .fail do |e|
      mutate.blocking false
      if e.class.name.to_s == 'ArgumentError'
        errors = JSON.parse(e.message.gsub('=>', ':'))
        errors.each do |k, v|
          errors[k] = v.join('; ')
        end
        mutate.errors errors
        puts "errors #{errors}"
      elsif e.is_a?(Hyperloop::Operation::ValidationException)
        mutate.errors e.errors.message
        puts "e.errors #{e.errors}"
        puts "e.errors.message #{e.errors.message}"
      end
      {}
    end
  end

end