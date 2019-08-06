class SettingsPassword < Hyperloop::Component
	param :user

	state old_password: ''
	state new_password: ''
	state new_password_confirmation: ''
	state errors: {}

	after_mount do
		mutate.blocking false
	end

	def render
		BlockUi(tag: "div", blocking: state.blocking, class: 'auth-settings') do
			div(class: 'border-bottom mb-4') do
				h4(class: 'mb-3') { 'Zmień swoje hasło' }
			end
			div() do
				div(class: 'row') do
					div(class: 'col-12 col-md-7') do

						div(class: 'pt-4') do
							FormGroup(label: "Twoje obecne hasło", error: state.errors['old_password']) do
								input(value: state.old_password, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['old_password'].present?}", placeholder: "Twoje obecne hasło").on :change do |e|
									mutate.old_password e.target.value
									mutate.errors['old_password'] = nil
								end
							end

							FormGroup(label: "Nowe hasło", error: state.errors['new_password']) do
								input(value: state.new_password, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['new_password'].present?}", placeholder: "Nowe hasło").on :change do |e|
									mutate.new_password e.target.value
									mutate.errors['new_password'] = nil
								end
							end

							FormGroup(label: "Powtórz nowe hasło", error: state.errors['new_password_confirmation']) do
								input(value: state.new_password_confirmation, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['new_password_confirmation'].present?}", placeholder: "Powtórz nowe hasło").on :change do |e|
									mutate.new_password_confirmation e.target.value
									mutate.errors['new_password_confirmation'] = nil
								end
							end

							div(class: 'row') do
								div(class: 'col-6') do
									button(class: 'btn btn-secondary mt-3', type: "button") do
										'Zmień'
									end.on(:click) do |e|
										e.prevent_default
										save_new_password
									end
								end
							end
						end
					end
				end
			end
		end
	end

	def save_new_password
		mutate.blocking true
		ProcessUserPasswordChange.run(
			old_password: state.old_password,
			new_password: state.new_password,
			new_password_confirmation: state.new_password_confirmation
		).then do |response|
			mutate.blocking false
			mutate.errors {}
			mutate.old_password ''
			mutate.new_password ''
			mutate.new_password_confirmation ''
			`toast.dismiss(); toast.success('Zmiana hasła zakończona powodzeniem', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
		end.fail do |e|
			if e.is_a?(Hyperloop::Operation::ValidationException)
				`toast.error('Formularz zawiera błedy.')`
				mutate.errors e.errors.message
			elsif e.is_a?(Exception)
				`toast.error('Wystąpił błąd! Upewnij się czy obecne hasło jest poprawne.')`
			end
			mutate.blocking false
		end
	end
end