class SettingsPin < Hyperloop::Component
	param :user

	state errors: {}
	state :old_pin
	state :new_pin
	state :new_pin_confirmation
	state blocking: false

	after_mount do
		mutate.blocking false
	end

	def render
		BlockUi(tag: "div", blocking: state.blocking, class: 'auth-settings') do
			div(class: 'border-bottom') do
				h4(class: 'mb-3') { 'Zmień PIN' }
				div(class: 'text-gray text-book') {'Aby ustawić nowy kod zabezpieczający dla twojego konta musisz najpierw podać stary kod PIN. Pamiętaj, że musi mieć on co najmniej 4 cyfry.'}
			end
			div(class: 'pt-4') do
				FormGroup(label: "Stary PIN", error: state.errors['old_pin']) do
					input(value: state.old_pin, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['old_pin'].present?}", placeholder: "Stary PIN").on :change do |e|
						mutate.old_pin e.target.value
						mutate.errors['old_pin'] = nil
					end
				end

				FormGroup(label: "Nowy PIN", error: state.errors['new_pin']) do
					input(value: state.new_pin, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['new_pin'].present?}", placeholder: "Nowy PIN").on :change do |e|
						mutate.new_pin e.target.value
						mutate.errors['new_pin'] = nil
					end
				end

				FormGroup(label: "Powtórz nowy PIN", error: state.errors['new_pin_confirmation']) do
					input(value: state.new_pin_confirmation, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['new_pin_confirmation'].present?}", placeholder: "Powtórz nowy PIN").on :change do |e|
						mutate.new_pin_confirmation e.target.value
						mutate.errors['new_pin_confirmation'] = nil
					end
				end

				div(class: 'row') do
					div(class: 'col-6') do
						button(class: 'btn btn-secondary mt-3', type: "button") do
							'Zmień'
						end.on(:click) do |e|
							e.prevent_default
							save_new_pin
						end
					end
				end
			end
		end
	end

	def save_new_pin
		mutate.blocking true
		ProcessUserPinChange.run(
			old_pin: state.old_pin,
			new_pin: state.new_pin,
			new_pin_confirmation: state.new_pin_confirmation
		).then do |response|
			mutate.blocking false
			mutate.old_pin ''
			mutate.new_pin ''
			mutate.errors {}
			mutate.new_pin_confirmation = nil
			`toast.dismiss(); toast.success('Zmiana PINu zakończona powodzeniem', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
		end.fail do |e|
			if e.is_a?(Hyperloop::Operation::ValidationException)
				`toast.error('Formularz zawiera błedy.')`
				mutate.errors e.errors.message
			elsif e.is_a?(Exception)
				`toast.error('Wystąpił błąd! Upewnij się czy twój stary PIN jest poprawny.')`
			end
			mutate.blocking false
		end
	end
end