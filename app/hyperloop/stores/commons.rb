class Commons < Hyperloop::Store

  state is_initially_loaded: false

  MAP_OPTIONS = {
    types: ['(cities)'],
    componentRestrictions: {country: 'pl'}
	}

	MAIN_CITIES = [
		{ value: "Warszawa, Polska", label: "Warszawa" },
		{ value: "Kraków, Polska", label: "Kraków" },
		{ value: "Łódź, Polska", label: "Łódź" },
		{ value: "Wrocław, Polska", label: "Wrocław" },
		{ value: "Poznań, Polska", label: "Poznań" },
		{ value: "Gdańsk, Polska", label: "Gdańsk" },
		{ value: "Szczecin, Polska", label: "Szczecin" },
		{ value: "Bydgoszcz, Polska", label: "Bydgoszcz" },
		{ value: "Lublin, Polska", label: "Lublin" },
		{ value: "Katowice, Polska", label: "Katowice" }
	]

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

  BODY_TYPES = ['Przeciętna', 'Kilka kilogramów za dużo', 'Atletyczna', 'Umięśniona', 'Szczupła']

  HEIGHT_MAPPING = {
    "<150"      => {:min=>100, :max=>149},
    "150 - 160" => {:min=>150, :max=>160},
    "161 - 170" => {:min=>161, :max=>170},
    "171 - 180" => {:min=>171, :max=>180},
    "181 - 190" => {:min=>181, :max=>190},
    "191 - 200" => {:min=>191, :max=>200},
    "201 - 210" => {:min=>201, :max=>210},
    "211 - 220" => {:min=>211, :max=>220},
    ">220"      => {:min=>221, :max=>300}
  }

  USER_SORT_OPTIONS = [
    { value: 'created_at desc',     label: 'Najnowsze'    },
    { value: 'created_at asc',      label: 'Najstarsze'   }
    # { value: 'online',             label: 'Teraz online'  },
    # { value: 'last_seen',         label: 'Ostatnio byli' }
  ]

  def self.account_kinds
    [
      {label: 'Kobieta', value: 'woman'},
      {label: 'Mężczyzna', value: 'man'},
      {label: 'Para hetero', value: 'couple'},
      {label: 'Para kobiet', value: 'women_couple'},
      {label: 'Para mężczyzn', value: 'men_couple'},
      {label: 'TGSV', value: 'tgsv'}
    ]
  end

  def self.is_initially_loaded
    state.is_initially_loaded
  end


  def self.loaded_initially
    puts "QUIET IN STORE? #{ReactiveRecord::WhileLoading.quiet?}"
    mutate.is_initially_loaded true
  end

  def self.account_kinds_declined
    [
      {label: 'Kobiet', value: 'woman'},
      {label: 'Mężczyzn', value: 'man'},
      {label: 'Par hetero', value: 'couple'},
      {label: 'Par kobiet', value: 'women_couple'},
      {label: 'Par mężczyzn', value: 'men_couple'},
      {label: 'TGSV', value: 'tgsv'}
    ]
  end

  def self.cities
    [
      {label: 'Łódź', value: 'Łódź'},
      {label: 'Warszawa', value: 'warszawa'}
    ]
  end


  def self.photo_version element, version
    if element.present? && element.is_a?(String)
      proper_element = JSON.parse(element.gsub('=>', ':').gsub('nil', 'null'))
      if proper_element
        return proper_element[version]['url']
      end
    elsif element.present? && element.is_a?(Hash)
      return element[version]['url']
    end
  end

  def self.process_3_state_checkbox e
    if (e.target.readOnly)
      e.target.checked = e.target.readOnly = false
    elsif (!e.target.checked)
      e.target.readOnly = e.target.indeterminate = true
    end
  end

end