class SettingsEmail < Hyperloop::Component
	param :user

	state password: ''
	state new_email: ''
	state new_email_confirmation: ''
	state errors: {}
	state blocking: false

	after_mount do
		mutate.blocking false
	end

	def render
		BlockUi(tag: "div", blocking: state.blocking, class: 'auth-settings') do
			div(class: 'border-bottom mb-4') do
				h4(class: 'mb-3') { 'Edytuj swój adres e-mail' }
			end
			div() do
				div(class: 'row') do
					div(class: 'col-12 col-md-7') do

						div(class: 'pt-4') do
							FormGroup(label: "Twoje hasło", error: state.errors['password']) do
								input(value: state.password, type: "password", class: "form-control #{'is-invalid' if (state.errors || {})['password'].present?}", placeholder: "Twoje hasło").on :change do |e|
									mutate.password e.target.value
									mutate.errors['password'] = nil
								end
							end

							FormGroup(label: "Nowy email", error: state.errors['new_email']) do
								input(value: state.new_email, type: "text", class: "form-control #{'is-invalid' if (state.errors || {})['new_email'].present?}", placeholder: "Nowy email").on :change do |e|
									mutate.new_email e.target.value
									mutate.errors['new_email'] = nil
								end
							end

							FormGroup(label: "Powtórz nowy email", error: state.errors['new_email_confirmation']) do
								input(value: state.new_email_confirmation, type: "text", class: "form-control #{'is-invalid' if (state.errors || {})['new_email_confirmation'].present?}", placeholder: "Powtórz nowy email").on :change do |e|
									mutate.new_email_confirmation e.target.value
									mutate.errors['new_email_confirmation'] = nil
								end
							end

							div(class: 'row') do
								div(class: 'col-6') do
									button(class: 'btn btn-secondary mt-3', type: "button") do
										'Zmień'
									end.on(:click) do |e|
										e.prevent_default
										save_new_email
									end
								end
							end
						end
					end
				end
			end
		end
	end

	def save_new_email
		mutate.blocking true
		ProcessUserEmailChange.run(
			password: state.password,
			new_email: state.new_email,
			new_email_confirmation: state.new_email_confirmation
		).then do |response|
			mutate.blocking false
			mutate.errors {}
			mutate.password ''
			mutate.new_email ''
			mutate.new_email_confirmation ''
			`toast.dismiss(); toast.success('Zmiana adresu zakończona powodzeniem', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
		end.fail do |e|
			if e.is_a?(Hyperloop::Operation::ValidationException)
				`toast.error('Formularz zawiera błedy.')`
				mutate.errors e.errors.message
			elsif e.is_a?(Exception)
				`toast.error('Wystąpił błąd! Upewnij się czy poprawnie wpisałeś swoje hasło.')`
			end
			mutate.blocking false
		end
	end
end