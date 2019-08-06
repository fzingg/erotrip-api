class HotlineEditModal < Hyperloop::Component
  include BaseModal

  state hotline: { city: '' }
  state errors: {}

  state current_file: {
    result: nil,
    src: nil,
    filename: nil,
    filetype: nil,
    error: nil
  }

  before_mount do
    if CurrentUserStore.current_user.blank?
      ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('HotlineNewModal', { size_class: 'modal-lg' }) } })
      close
    else
      Hotline.find(params.attributes[:hotline].id).load(:id, :content, :user_id, :is_anonymous, :lat, :lon, :city).then do |data|
        hot = Hotline.find(params.attributes[:hotline].id)
        mutate.hotline({
          id: hot.id,
          content: hot.content,
          user_id: hot.user_id,
          is_anonymous: hot.is_anonymous,
          lat: hot.lat,
          lon: hot.lon,
          city: hot.city
        })
      end
    end
  end

  def title
    'Edytuj ogłoszenie hotline'
  end

  def city_selected(val)
    mutate.hotline['city'] = val
    if React::IsomorphicHelpers.on_opal_client?
      Native(`window`).GeocodeByAddress(val)
      .then do |results|
        result = Hash.new(Array.new(results.to_n)[0])

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
  end

  def render_modal
    span do
      div(class: 'modal-body') do
        div(class: 'row') do

          div(class: 'col-3 col-md-3') do
            img(class: 'img-fit br-10', src: CurrentUserStore.current_user.try(:avatar_url).present? ? "#{CurrentUserStore.current_user.try(:avatar_url)}&version=#{state.hotline['is_anonymous'] ? 'blurred' : 'normal'}" : '/assets/user-blank.png')
          end

          div(class: 'col-9 col-md-9') do
            FormGroup(error: state.errors['content'], classNames: 'mb-0') do
              textarea(
                value: state.hotline['content'],
                placeholder: "Treść",
                name: 'content',
                class: "form-control",
                maxLength: 140
              ).on :change do |e|
                mutate.errors['content'] = nil
                mutate.hotline['content'] = e.target.value
              end
            end

            div(class: 'row mt-2 mb-2') do
              div(class: 'col col-12 col-md-6 order-2 order-md-1 d-none d-md-flex') do
                div(class: 'form-check form-check-inline mb-0') do
                  label(class: 'form-check-label') do
                    input.form_check_input(type: "checkbox", checked: !!state.hotline['is_anonymous']).on :change do |e|
                      mutate.hotline['is_anonymous'] = e.target.checked
                    end
                    span
                    'Anonimowo'
                  end
                end
              end

              div(class: 'col col-12 col-md-6 text-rięht order-1 order-md-2') do
                span(class: "text-regular #{'text-danger' if (state.hotline['content'] || '').size >= 140}") { "Pozostało #{140 - (state.hotline['content'] || '').size} znaków" }
              end
            end

            div(class: 'row') do
              div(class: 'col-12 col-xl-6 location d-none d-md-flex') do
                GooglePlacesAutocomplete(
                  inputProps: { value: state.hotline['city'], onChange: proc{ |e| city_changed(e)}, placeholder: 'Miejscowość'}.to_n,
                  options: Commons::MAP_OPTIONS.to_n,
                  googleLogo: false,
                  classNames: Commons::CSS_CLASSES.to_n,
                  onSelect: proc{ |e| city_selected(e)}
                )
              end
            end

          end
        end

        div(class: 'row d-md-none') do
          div(class: 'col col-12 col-md-6 order-2 order-md-1') do
            div(class: 'form-check form-check-inline mb-0') do
              label(class: 'form-check-label') do
                input.form_check_input(type: "checkbox").on :change do |e|
                  mutate.hotline['is_anonymous'] = e.target.checked
                end
                span
                'Anonimowo'
              end
            end
          end
        end

        div(class: 'row d-md-none') do
          div(class: 'col-12 col-xl-6 location') do
            GooglePlacesAutocomplete(
              inputProps: { value: state.hotline['city'], onChange: proc{ |e| city_changed(e)}, placeholder: 'Miejscowość'}.to_n,
              options: Commons::MAP_OPTIONS.to_n,
              googleLogo: false,
              classNames: Commons::CSS_CLASSES.to_n,
              onSelect: proc{ |e| city_selected(e)}
            )
          end
        end
      end

      div(class: 'modal-footer', style: {justifyContent: 'center', paddingTop: 0}) do
        button(class: 'btn btn-secondary btn-cons mt-3 mb-0', type: "button") do
          'Zapisz zmiany'
        end.on :click do
          save_hotline
        end
      end
    end
  end

  # def avatar_url
  #   if CurrentUserStore.current_user["avatar_url"] && !state.hotline['is_anonymous']
  #     CurrentUserStore.current_user["avatar_url"]
  #   elsif CurrentUserStore.current_user["blurred_avatar_url"] && state.hotline['is_anonymous']
  #     CurrentUserStore.current_user["blurred_avatar_url"]
  #   else
  #     '/assets/user-blank.png'
  #   end
  # end

  def save_hotline
    mutate.hotline['acting_user'] = CurrentUserStore.current_user
    mutate.blocking true
    SaveHotline.run(state.hotline)
    .then do |data|
      mutate.blocking false
      `toast.dismiss(); toast.success('Zapisaliśmy zmiany w hotline.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      close
    end.fail do |e|
      mutate.blocking false
      puts "HOTLINE NOT SAVED, #{e.inspect}"
      `toast.error('Nie udało się zapisać hotline.')`
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

end