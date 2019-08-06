class RegistrationModal < Hyperloop::Component
	include BaseModal

	MAP_OPTIONS = {
		types: ['(cities)'],
		componentRestrictions: {country: 'pl'}
	}

	CSS_CLASSES = {
		root: 'google-places',
    input: 'form-control',
    autocompleteContainer: 'autocomplete-container'
	}

	INVALID_CSS_CLASSES = {
		root: 'google-places',
		input: 'form-control is-invalid',
		autocompleteContainer: 'autocomplete-container'
	}

  state :user do
    { birth_year: '', kind: '', birth_year_second_person: '', city: '', lon: '', lat: '' }
  end
  state errors: {}

  def render_modal
    if CurrentUserStore.current_user.present?
      render_logged_view
    else
      render_not_logged_view
    end
	end

  def title
    'Zarejestruj się'
  end

  def lonlat_present?
    state.user['lon'].present? && state.user['lat'].present?
  end

  def render_not_logged_view
    span do
      div(class: 'modal-body modal-body-registration') do
        if (state.errors || {})['base'].present?
          div(class: 'alert alert-danger') do
            (state.errors || {})['base']
          end
        end
        form do
					FormGroup(label: 'Rodzaj konta', error: state.errors['kind']) do
						SelectWithCheckboxes(placeholder: "Rodzaj konta", clearable: false, options: Commons.account_kinds, selection: state.user['kind'], className: "form-control #{'is-invalid' if (state.errors || {})['kind'].present?}").on :change do |e|
              mutate.user['kind'] = e.to_n || ''
              mutate.errors['kind'] = nil
            end
					end

          div(class: 'row') do

            div(class: 'col-6') do
							FormGroup(label: 'Imię', error: state.errors['name']) do
							  input(defaultValue: state.user['name'], type: "text", class: "form-control #{'is-invalid' if (state.errors || {})['name'].present?}", placeholder: "Imię").on :key_up do |e|
                  mutate.user['name'] = e.target.value
                  mutate.errors['name'] = nil
                end
							end
            end

            div(class: 'col-6') do
							FormGroup(label: "Rok urodzenia", error: state.errors['birth_year']) do
								SelectWithCheckboxes(placeholder: "Rok urodzenia",  clearable: false, maxHeight: "h-200", options: birth_dates.map{|year| {value: year, label: year} }, selection: state.user['birth_year'], className: "hehes form-control #{'is-invalid' if (state.errors || {})['birth_year'].present?}").on :change do |e|
                  mutate.user['birth_year'] = e.to_n || nil
                  mutate.errors['birth_year'] = nil
                end
							end
            end

          end

          div(class: "row #{'d-none' if !(state.user['kind'].present? && !['woman', 'man', 'tgsv'].include?(state.user['kind']))}") do

            div(class: 'col-6') do
							FormGroup(label: "Imię drugiej osoby", error: state.errors["name_second_person"]) do
								input(defaultValue: state.user['name_second_person'], type: "text", class: "form-control #{'is-invalid' if (state.errors || {})['name_second_person'].present?}", placeholder: "Imię drugiej osoby").on :key_up do |e|
                  mutate.user['name_second_person'] = e.target.value
                  mutate.errors['name_second_person'] = nil
                end
							end
            end

            div(class: 'col-6') do
							FormGroup(label: "Rok urodzenia drugiej osoby", error: state.errors['birth_year_second_person'], classNames: 'with-ellipsed-label d-block') do
								SelectWithCheckboxes(placeholder: "Rok urodzenia drugiej osoby", clearable: false,  maxHeight: "h-200", options: birth_dates.map{|year| {"value": year, "label": year} }, selection: state.user['birth_year_second_person'], maxHeight: "h-300", className: "form-control #{'is-invalid' if (state.errors || {})['birth_year_second_person'].present?}").on :change do |e|
                  mutate.user['birth_year_second_person'] = e.to_n || nil
                  mutate.errors['birth_year_second_person'] = nil
                end
							end
            end

          end

          div(class: 'row') do

            div(class: 'col-6') do
							FormGroup(label: "Miejscowość", error: state.errors['city']) do
								GooglePlacesAutocomplete(
              		inputProps: { value: state.user['city'], onChange: proc{ |e| city_changed(e)} , placeholder: 'Miejscowość'}.to_n,
              		options: MAP_OPTIONS.to_n,
              		googleLogo: false,
              		classNames: state.errors['city'].present? ? INVALID_CSS_CLASSES.to_n : CSS_CLASSES.to_n,
                  onSelect: proc{ |e| city_selected(e)}
              	)
							end
						end

            div(class: 'col-6') do
							FormGroup(label: "Adres e-mail", error: state.errors['email']) do
								input(defaultValue: state.user['email'], type: "email", class: "form-control #{'is-invalid' if (state.errors || {})['email'].present?}", placeholder: "Adres e-mail").on :key_up do |e|
                  mutate.user['email'] = e.target.value
                  mutate.errors['email'] = nil
                end
							end
            end

          end

          div(class: 'row') do

            div(class: 'col-6') do
							FormGroup(label: 'Hasło', error: state.errors['password']) do
								input(defaultValue: state.user['password'], type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['password'].present?}", placeholder: "Hasło").on :key_up do |e|
                  mutate.user['password'] = e.target.value
                  mutate.errors['password'] = nil
                end
							end
            end

            div(class: 'col-6') do
							FormGroup(label: "Powtórz hasło", error: state.errors['password_confirmation']) do
								input(defaultValue: state.user['password_confirmation'], type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['password_confirmation'].present?}", placeholder: "Powtórz hasło").on :key_up do |e|
                  mutate.user['password_confirmation'] = e.target.value
                  mutate.errors['password_confirmation'] = nil
                end
							end
            end

          end

          div(class: "form-check form-check-inline w-80p ml-10p") do
            label(class: "form-check-label #{'is-invalid' if (state.errors || {})['terms_acceptation'].present?}") do
              input.form_check_input(defaultValue: state.user['terms_acceptation'], type: "checkbox").on :change do |e|
                mutate.user['terms_acceptation'] = e.target.checked
                mutate.errors['terms_acceptation'] = nil
              end
              span do
                div do
                  span { 'Akceptuję' }
                  A(href: "", target: '_blank') { ' regulamin ' }
                  span { 'oraz oświadczam, że mam ukończone 18 lat.' }
                end
              end
            end
            if (state.errors || {})['terms_acceptation'].present?
              div(class: "invalid-feedback") do
                (state.errors || {})['terms_acceptation'].to_s;
              end
            end
          end

          div(class: "text-center") do
            BlockUi(tag: "div", blocking: state.blocking) do
              button.btn.btn_secondary.btn_cons.mt_4.mb_4(type: "submit") do
                'Zarejestruj się'
              end
            end
          end
        end.on :submit do |e|
          e.prevent_default
          register
        end
        p(class: "text-center") do
          span {'Nie pamiętasz hasła? '}
          a(class: "text-primary") do
            'Zrestartuj hasło'
          end.on :click do |e|
            reset_password
          end
        end
        p(class: "text-center") do
          span {'Masz już konto? '}
          a(class: "text-primary") do
            'Zaloguj się'
          end.on :click do |e|
            log_in
          end
        end
      end
    end
  end

  def render_logged_view
    span do
      div(class: 'modal-body') do
        p(class: 'text-center') { 'Jesteś aktualnie zalogowany! Wyloguj się, by przejść proces rejestracji' }
      end
      div(class: 'modal-footer text-center') do
        button(class: 'btn btn-secondary btn-cons mt-3 mb-3', type: "button") do
          'Zamknij okno'
        end.on :click do
          close
        end
      end
    end
  end


  def register
    unless state.blocking
      mutate.blocking(true)
      mutate.errors({})
      ProcessSignUp.run(state.user)
        .then do |response|
          mutate.blocking(false)
          `toast.dismiss(); toast.success('Zarejestrowaliśmy i zalogowaliśmy Cię! Witamy w EroTrip.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
          params.callback.call(true) if params.callback
          close
        end
        .fail do |e|
          # `console.log(e)`
          puts e.class.to_s
          mutate.blocking(false)
          `toast.error('Nie udało się zarejestrować.')`
          if e.is_a?(Hyperloop::Operation::ValidationException)
          # if e.class.to_s == 'Hyperloop::Operation::ValidationException'
            # puts e.errors.message
            puts "VALIDATION EXCEPTION #{e.errors.message} #{e.errors}"
            mutate.errors e.errors.message
          elsif e.is_a?(HTTP)
            if JSON.parse(e.body)['id'].present?
              CurrentUserStore.current_user_id! JSON.parse(e.body)['id']
              close
            end
            errors = JSON.parse(e.body)['errors']
            errors.each do |k, v|
              errors[k] = v.join('; ')
            end
            mutate.errors errors
            puts "HTTP EXCEPTION: #{errors}"
          end
          {}
        end
    end
  end

  def log_in
    ModalsService.open_modal('LoginModal', { callback: params.callback })
    close
  end

  def reset_password
    ModalsService.open_modal('ResetPasswordModal', { callback: params.callback })
    close
  end

  def birth_dates
    ((Time.now - 60.years).year..(Time.now - 18.years).year).to_a.reverse
  end

  def city_changed(val)
    mutate.user['city'] = val
    mutate.user['lon'] = nil
    mutate.user['lat'] = nil
  end

  def city_selected(val)
    if React::IsomorphicHelpers.on_opal_client?
      %x{
        window.GeocodeByAddress(#{val}).then(function(results) {
          var short_name = results[0]['address_components'][0]['short_name']
          var bounds = {
            a: {
              b: results[0]['geometry']['bounds']['b']['b'],
              f: results[0]['geometry']['bounds']['b']['f']
            },
            b: {
              b: results[0]['geometry']['bounds']['f']['b'],
              f: results[0]['geometry']['bounds']['f']['f']
            }
          }
          var location = {
            lat: results[0]['geometry']['location']['lat'](),
            lng: results[0]['geometry']['location']['lng']()
          }

          #{handle_geocode_response(`short_name`, `bounds`, `location`)}
        });
      }
    end
  end

  def handle_geocode_response short_name, bounds, location
    mutate.user['city'] = short_name
    # mutate.user['lonlat'] = Hash.new(location).values
    # puts "lon", Hash.new(location)[:lng]
    # puts "lat", Hash.new(location)[:lat]
    mutate.user['lon'] = Hash.new(location)[:lng]
    mutate.user['lat'] = Hash.new(location)[:lat]
    # puts "short_name", short_name
    # puts "bounds", Hash.new(bounds)
    # puts "location", Hash.new(location)

    # puts "USER ", Hash.new(state.user)
  end

end

