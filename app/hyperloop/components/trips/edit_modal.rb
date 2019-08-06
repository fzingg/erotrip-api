class EditTripModal < Hyperloop::Component
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

  @temp_description = ''

  state maps: nil
  state markers: []
  state waypoints_map: Hash.new
  state trip: {}
  state errors: {}

  before_mount do
    if CurrentUserStore.current_user.blank?
      ModalsService.open_modal('RegistrationModal', { callback: proc { ModalsService.open_modal('EditTripModal', {size_class: 'modal-lg', trip_id: params.attributes[:trip_id] }) } })
      close
    else
      Trip.find(params.attributes[:trip_id]).load(:id, :user_id, :arrival_time, :destinations, :description, :is_anonymous).then do |data|
        trip = Trip.find(params.attributes[:trip_id])
        puts trip.destinations
        trip.destinations["data"] = trip.destinations["data"].insert(1, {lat: nil, lon: nil, city: ''}) if trip.destinations["data"].count == 2
        mutate.trip({
          id: trip.id,
          user_id: trip.user_id,
          arrival_time: trip.arrival_time,
          destinations: trip.destinations,
          description: trip.description,
          is_anonymous: trip.is_anonymous,
          arrival_hour: trip.arrival_time.hour,
          arrival_minutes: trip.arrival_time.min == 0 ? '00' : trip.arrival_time.min
        })
        puts "dest #{state.trip['description']}"
        after(0) do
          if state.maps.present?
            update_map
          end
        end
      end
    end
  end

  def render_modal
    puts 'RENDERING!'
    BlockUi(tag: "span", blocking: state.blocking) do
      div(class: 'modal-body') do
        if (state.errors || {})['base'].present?
          div(class: 'alert alert-danger') do
            (state.errors || {})['base']
          end
        end

        if state.trip.present? && state.trip['id'].present?

          form do
            div(class: 'row') do
              div(class: 'col col-12 col-lg-6 order-2 order-lg-1') do
                FormGroup(label: "Miejscowość początkowa", error: state.errors["destinations[0]['city']"], classNames: 'no-label') do
                  div(class: "d-flex align-items-center google-places-wrapper") do
                    span(class: "from d-flex d-lg-none") {'Z:'}
                    GooglePlacesAutocomplete(
                      inputProps: { value: state.trip['destinations']['data'][0]['city'], onChange: proc{ |e| city_changed(0, e)} , placeholder: 'Miejscowość początkowa'}.to_n,
                      options: MAP_OPTIONS.to_n,
                      googleLogo: false,
                      defaultSuggestions: [
                        { suggestion: "Warszawa", placeId: 0, active: false, index: 0, formattedSuggestion: nil },
                        { suggestion: "Kraków", placeId: 1, active: false, index: 1, formattedSuggestion: nil },
                        { suggestion: "Łódź", placeId: 2, active: false, index: 2, formattedSuggestion: nil },
                        { suggestion: "Wrocław", placeId: 3, active: false, index: 3, formattedSuggestion: nil },
                        { suggestion: "Poznań", placeId: 4, active: false, index: 4, formattedSuggestion: nil }
                      ].to_n,
                      # debounce: 400,
                      classNames: state.errors["destinations[0]['city']"].present? ? INVALID_CSS_CLASSES.to_n : CSS_CLASSES.to_n,
                      onSelect: proc{ |e| city_selected(0, e)}
                    )
                  end
                end
                FormGroup(label: "Miejscowość docelowa", error: state.errors["destinations[#{state.trip['destinations']['data'].size - 1}]['city']"], classNames: 'no-label') do
                  div(class: "d-flex align-items-center google-places-wrapper") do
                   span(class: "to d-flex d-lg-none") {'DO:'}
                    GooglePlacesAutocomplete(
                      inputProps: { value: state.trip['destinations']['data'][-1]['city'], onChange: proc{ |e| city_changed(state.trip['destinations']['data'].size - 1, e)} , placeholder: 'Miejscowość docelowa'}.to_n,
                      options: MAP_OPTIONS.to_n,
                      googleLogo: false,
                      defaultSuggestions: [
                        { suggestion: "Warszawa", placeId: 0, active: false, index: 0, formattedSuggestion: nil },
                        { suggestion: "Kraków", placeId: 1, active: false, index: 1, formattedSuggestion: nil },
                        { suggestion: "Łódź", placeId: 2, active: false, index: 2, formattedSuggestion: nil },
                        { suggestion: "Wrocław", placeId: 3, active: false, index: 3, formattedSuggestion: nil },
                        { suggestion: "Poznań", placeId: 4, active: false, index: 4, formattedSuggestion: nil }
                      ].to_n,
                      # debounce: 400,
                      classNames: state.errors["destinations[#{(state.trip['destinations'].size - 1).to_s}]['city']"].present? ? INVALID_CSS_CLASSES.to_n : CSS_CLASSES.to_n,
                      onSelect: proc{ |e| city_selected(state.trip['destinations']['data'].size - 1, e)},
                    )
                  end
                end
                div do
                  label {'Przez (opcjonalnie)'}
                end
                state.trip['destinations']['data'][1..state.trip['destinations']['data'].size - 2].each_with_index do |destination, index|
                  FormGroup(label: false, error: state.errors["destinations[#{(index + 1).to_s}]['city']"], classNames: 'relative-pos input-button-hoverer') do
                    GooglePlacesAutocomplete(
                      inputProps: { value: destination['city'], onChange: proc{ |e| through_city_changed(index + 1, e)} , placeholder: 'Przez'}.to_n,
                      options: MAP_OPTIONS.to_n,
                      googleLogo: false,
                      defaultSuggestions: [
                        { suggestion: "Warszawa", placeId: 0, active: false, index: 0, formattedSuggestion: nil },
                        { suggestion: "Kraków", placeId: 1, active: false, index: 1, formattedSuggestion: nil },
                        { suggestion: "Łódź", placeId: 2, active: false, index: 2, formattedSuggestion: nil },
                        { suggestion: "Wrocław", placeId: 3, active: false, index: 3, formattedSuggestion: nil },
                        { suggestion: "Poznań", placeId: 4, active: false, index: 4, formattedSuggestion: nil }
                      ].to_n,
                      # debounce: 400,
                      classNames: state.errors["destinations[#{(index + 1).to_s}]['city']"].present? ? INVALID_CSS_CLASSES.to_n : CSS_CLASSES.to_n,
                      onSelect: proc{ |e| city_selected(index + 1, e)},
                    )
                    div(class: "remove-input-button #{'d-none' if index == 0}") do
                      i(class: "ero-cross")
                    end.on :click do |e|
                      e.prevent_default
                      e.stop_propagation
                      new_data = state.trip['destinations']['data'].dup
                      new_data.delete_at(index + 1)
                      mutate.trip['destinations']['data'] = new_data
                      update_map
                    end
                  end
                end

                div(class: "d-flex justify-content-center justify-content-md-start") do
                  button(class: 'btn btn-primary btn-new-trip-destination', type: 'button') do
                    'Dodaj następne'
                  end.on(:click) { add_destination }
                end

                FormGroup(label: "Data i godzina", error: state.errors['arrival_time']) do
									div(class:'row form-inline trip-modal-time') do
										div(class: "datetime-picker") do
											Datetime(
												inputProps: {readOnly: true}.to_n,
												isValidDate: `function(current, selected) {var yesterday = moment().subtract( 1, 'day' );  return current.isAfter( yesterday );}`,
												value: state.trip['arrival_time'],
												defaultValue: Time.now,
												input: true,
												timeFormat: false,
												locale: "pl",
												closeOnSelect: true,
                        className: 'date-input',
												onChange: proc{ |val| changed_date val, "date" }
											)
										end

										div(class: 'hour-input') do
											TableSelect(options: AddTripModal.hour_options, value: state.trip['arrival_hour'], inputClassName: "form-control").on :change do |e|
												changed_date e.to_n["value"], "hour"
											end
										end

										div(class: 'minutes-input') do
											TableSelect(options: AddTripModal.minutes_options, value: state.trip['arrival_minutes'], inputClassName: "form-control", optionClassName: "two-in-row").on :change do |e|
												changed_date e.to_n["value"], "minutes"
											end
										end

                    # div(class: 'hour-input') do
                    #   Select(placeholder: "", clearable: false, backspaceRemoves: false, deleteRemoves: false, options: AddTripModal.hour_options, selection: state.trip['arrival_hour'], className: "four-in-line drop-up", drop_up: true).on :change do |e|
                    #     changed_date e.to_n, "hour"
                    #   end
                    # end
                    # div(class: 'minutes-input') do
                    #   Select(placeholder: "", clearable: false, backspaceRemoves: false, deleteRemoves: false, options: AddTripModal.minutes_options, selection: state.trip['arrival_minutes'], className: "two-in-line drop-up", drop_up: true).on :change do |e|
                    #     changed_date e.to_n, "minutes"
                    #   end
										# end

                end
              end

              div(class: 'form-check form-check-inline mb-0 margin-left-15 mt-2 mb-2') do
                label(class: 'form-check-label big-round-label anonymous-checkbox', style: {lineHeight: '28px'}) do
                  input.form_check_input(type: "checkbox", checked: state.trip['is_anonymous']).on :change do |e|
                    mutate.errors['is_anonymous'] = nil
                    mutate.trip['is_anonymous'] = e.target.checked
                  end
                  span
                  div(class: 'd-flex align-items-center anonymous-label') {'Dodaj anonimowo'}
                end
              end

              p(class: 'text-gray-light') do
                "#{anonymous_description}"
              end

              div(class: "d-block d-lg-none") do
                  FormGroup(label: "Opis", error: state.errors['description'], classNames: 'mb-0 trip-description') do
                    Textarea(
                      value: state.trip['description'],
                      placeholder: 'Opis',
                      onChange: proc{ |val| textarea_changed_saved_in_variable(val) }
                    )
                  end
                end
              end
              div(class: 'col col-lg-6 order-1 order-lg-2') do
                div(class: 'row') do
                  div(class: 'col google-map') do
                    center = nil
							      if state.trip['destinations']['data'][0] && state.trip['destinations']['data'][0]['lon'].present? && state.trip['destinations']['data'][0]['lat'].present?
								      center = [state.trip['destinations']['data'][0]['lat'], state.trip['destinations']['data'][0]['lon']]
							      end
                    GoogleMapReact(
                      options: { fullscreenControl: false }.to_n,
								      yesIWantToUseGoogleMapApiInternals: true,
								      onGoogleApiLoaded: proc{ |map| init_map map },
								      zoom: if center.present? then 9 else 5 end,
								      center: if center.present? then center else { lng: 19, lat: 52 }.to_n end
							      ) do
                    end
                  end
                end
                div(class: 'row') do
                  div(class: 'col d-none d-lg-block') do
                    FormGroup(label: "Opis", error: state.errors['description'], classNames: 'mb-0 trip-description') do
                      Textarea(
                        value: state.trip['description'],
                        placeholder: 'Opis',
                        onChange: proc{ |val| textarea_changed_saved_in_variable(val) }
                      )
                    end
                  end
                end
              end
            end
          end
        else
          div(class: 'dots-container') do
            div(class: 'animated-dots') do
              span {'.'}
              span {'.'}
              span {'.'}
            end
          end
        end
      end
    end

    div(class: 'modal-footer justify-content-center align-items-center') do
      div(class: "d-flex justify-content-center ea-flex-1") do
        button(class: 'btn btn-secondary btn-cons mr-2', type: "button") do
          'Zapisz Przejazd'
          end.on :click do
            save_trip
          end
        button(class: 'btn btn-outline-primary btn-cons btn-outline-cancel text-gray', type: "button") do
          'Anuluj'
        end.on :click do
          close
        end
      end
    end
  end

  def title
    'Edytuj przejazd'
  end

  def anonymous_description
    "Będziesz otrzymywał wiadomości, ale Twój profil nie będzie widoczny. Odblokujesz go wybranym osobom w dowolnym momencie."
  end

  def textarea_changed val
    mutate.trip['description'] = val
  end

  def textarea_changed_saved_in_variable val
    @temp_description = val
  end

  def lonlat_present? point
    point['lon'].present? && point['lat'].present?
  end

  def self.hour_options
    arr = []
    24.times { |i| arr.push({label: "#{i}", value: i}) }
    arr
  end

  def self.minutes_options
    arr = []
    6.times { |i| arr.push({label: i == 0 ? '00' : "#{i * 10}", value: i == 0? '00' : i * 10}) }
    arr
  end

  def changed_date val, source
    if source == 'minutes'
        mutate.trip['arrival_minutes'] = val
        `
        var date = new Date(#{state.trip['arrival_time']});
        date.setMinutes(#{state.trip['arrival_minutes']})
        `
        date = `date`
        mutate.trip['arrival_time'] = Time.parse(date);
    end

    if source == 'hour'

      mutate.trip['arrival_hour'] = val
       `
      var date = new Date(#{state.trip['arrival_time']});
      date.setHours(#{state.trip['arrival_hour']})
      `
      date = `date`
      mutate.trip['arrival_time'] = Time.parse(date);
    end

    if source == "date"
      `
      var date = new Date(val);
      date.setHours(#{state.trip['arrival_hour']})
      date.setMinutes(#{state.trip['arrival_minutes']})
      `
      date = `date`
      mutate.trip['arrival_time'] = Time.parse(date);
    end
  end

  def add_destination position
    hide_destiniation_errors
    mutate.trip['destinations']['data'] = state.trip['destinations']['data'].insert(-2, { city: '', lon: nil, lat: nil  })
  end

  def remove_destination position
    old_destinations = state.trip['destinations']['data']
    old_destinations[position]['city'] = ''
    old_destinations[position]['lat'] = old_destinations[position]['lon']  = nil
    mutate.trip['destinations']['data'] = old_destinations
    mutate.waypoints_map[position] = ''
    update_map
  end



  def init_map map
    %x{
      var directionsDisplay = new google.maps.DirectionsRenderer( { suppressMarkers: true } );
      directionsDisplay.setMap(map.map);
      map.maps.directionsDisplay = directionsDisplay;
      map.maps.directionsService = new google.maps.DirectionsService();
      #{mutate.maps `map`}
    }
    update_map
  end

  def update_map
    %x{
      var map = #{state.maps}
      var trips = #{state.trip.to_n}
      if (!trips.destinations || !trips.destinations.data) {
        trips.destinations = { data: [] }
      }
      var lastTripsIndex = trips.destinations.data.length - 1;
      var waypoints = [];
      var markers = #{state.markers.to_n};
      for(var i = 0; i < markers.length; ++i ) {
        markers[i].setMap(null);
      }
      markers = [];

      if (trips.destinations.data.length > 2) {
        for(var i = 0; i < trips.destinations.data.length; ++i) {
          if (i > 0 && i < lastTripsIndex && trips.destinations.data[i].lat && trips.destinations.data[i].lon) {
            waypoints.push({ location: new google.maps.LatLng(trips.destinations.data[i].lat, trips.destinations.data[i].lon), stopover: true })
          }
        }
      }

      for(var i = 0; i < trips.destinations.data.length; ++i) {
        var dest = trips.destinations.data[i];
        if (dest.lat && dest.lon) {
          var color = (i == trips.destinations.data.length - 1) ? 'E8126B' : '00C2F0'
          var markerIcon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=•|' + color;
          var marker = new google.maps.Marker({
                  position: new google.maps.LatLng(dest.lat, dest.lon),
                  map: map.map,
                  icon: markerIcon,
                  city: dest.city
          });
          markers.push(marker);
          console.log("PUSHED MARKER FROM", dest.lat, dest.lon);
        }
      }

      #{mutate.markers `markers`}

      if (!trips.destinations.data[lastTripsIndex].city && lastTripsIndex > 1) {
        lastTripsIndex--;
      }

      map.maps.directionsService.route({
        origin: new google.maps.LatLng(trips.destinations.data[0].lat,trips.destinations.data[0].lon),
        waypoints: waypoints,
        destination: new google.maps.LatLng(trips.destinations.data[lastTripsIndex].lat,trips.destinations.data[lastTripsIndex].lon),
        travelMode: google.maps.TravelMode.DRIVING,
      }, function(response, status) {
        if (status === 'OK') {
          map.maps.directionsDisplay.setDirections(response);
        } else {
          map.maps.directionsDisplay.setDirections({routes: []});
          console.log('Directions request failed due to ' + status);
        }
      });
      }
  end

  def hide_destiniation_errors index
    if index
      mutate.errors["destinations[#{index}]['city']"] = nil
    else
      (state.trip['destinations']['data'].try(:size) || 0).times do |i|
        if state.errors["destinations[#{i}]['city']"]
          mutate.errors["destinations[#{i}]['city']"] = nil
        end
      end
    end
  end

  def city_changed(destination, val)
    hide_destiniation_errors destination
    through_city_changed(destination, val)
  end

  def through_city_changed(index, val)
    state.waypoints_map[index] = val if state.waypoints_map[index].try(:empty?) && state.waypoints_map[index]
    if state.waypoints_map[index] && state.waypoints_map[index].length  > val.length
      remove_destination index
    else
     mutate.waypoints_map[index] = val
     mutate.trip['destinations']['data'][index]['city'] = val
     mutate.trip['destinations']['data'][index]['lon'] = nil
     mutate.trip['destinations']['data'][index]['lat'] = nil
    end
  end

  def added_destination
    # HTTP.get('http://maps.googleapis.com/maps/api/distancematrix/json?origins=41.43206,-81.38992&destinations=40.6655101,-73.89188969999998&language=pl')
    #   .then do |response|
    #   end
  end

  def save_trip
    mutate.trip['description'] = @temp_description
    mutate.trip['acting_user'] = CurrentUserStore.current_user
    mutate.blocking true

    destinations = state.trip['destinations']['data'].select { |item| item.present? && item['city'].present? && item['lat'].present? && item['lon'].present? }.compact
    mutate.trip['destinations']['data'] = destinations

    SaveTrip.run(state.trip)
    .then do |data|
      puts 'tutu'
      mutate.blocking false
      puts "TRIP SAVED, #{data.inspect}"
      `toast.dismiss(); toast.success('Zapisaliśmy przejazd.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
      close
    end
    .fail do |e|
      mutate.blocking false
      puts "TRIP NOT SAVED, #{e.inspect}, #{e.message}"
      if e.backtrace.present?
        puts e.backtrace.join("\n")
      end
      # `toast.error('Nie udało się zapisać przejazdu.')`
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



    # mutate.trip['acting_user'] = CurrentUserStore.current_user
    # mutate.blocking true
    # SaveTrip.run(state.trip)
    # .then do |data|
    #   mutate.blocking false
    #   puts "TRIP SAVED, #{data.inspect}"
    #   `toast.dismiss(); toast.success('Zapisaliśmy przejazd.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
    #   close
    # end
    # .fail do |e|
    #   mutate.blocking false
    #   puts "TRIP NOT SAVED, #{e.inspect}"
    #   `toast.error('Nie udało się zapisać przejazdu.')`
    #   if e.class.name.to_s == 'ArgumentError'
    #     errors = JSON.parse(e.message.gsub('=>', ':'))
    #     errors.each do |k, v|
    #       errors[k] = v.join('; ')
    #     end
    #     mutate.errors errors
    #   elsif e.is_a?(Hyperloop::Operation::ValidationException)
    #     mutate.errors e.errors.message
    #   end
    #   {}
    # end
  end

  def city_selected(destination, val)
    if React::IsomorphicHelpers.on_opal_client?
      %x{
        window.GeocodeByAddress(#{val}).then(function(results) {
          var short_name = results[0]['address_components'][0]['short_name']
          var bounds = {
            a: {
              b: results[0]['geometry']['bounds'] && results[0]['geometry']['bounds']['b'] ? results[0]['geometry']['bounds']['b']['b'] : '',
              f: results[0]['geometry']['bounds'] && results[0]['geometry']['bounds']['b'] ?  results[0]['geometry']['bounds']['b']['f'] : ''
            },
            b: {
              b: results[0]['geometry']['bounds'] && results[0]['geometry']['bounds']['f'] ?  results[0]['geometry']['bounds']['f']['b'] : '',
              f: results[0]['geometry']['bounds'] && results[0]['geometry']['bounds']['f'] ? results[0]['geometry']['bounds']['f']['f'] : ''
            }
          }
          var location = {
            lat: results[0]['geometry']['location']['lat'](),
            lng: results[0]['geometry']['location']['lng']()
          }

          #{handle_geocode_response(destination, `short_name`, `bounds`, `location`)}
          #{update_map}
        });
      }
    end
  end

  def handle_geocode_response destination, short_name, bounds, location
    mutate.trip['destinations']['data'][destination]['city'] = short_name
    mutate.waypoints_map[destination] = short_name
    mutate.trip['destinations']['data'][destination]['lon'] = Hash.new(location)[:lng]
    mutate.trip['destinations']['data'][destination]['lat'] = Hash.new(location)[:lat]
  end



end

