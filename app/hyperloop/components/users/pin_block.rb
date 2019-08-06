class PinBlock < Hyperloop::Component
	state pin_error: false
	state pin: ""
	state pin_confirmation: ""

	def render
		div(class: "pin-section") do
			div(class: "d-flex align-items-center justify-content-center mb-2 mb-md-0") do
				img(src:'/assets/password-white-small.png')
			end
			div(class: "pin-text ml-0 ml-md-3 mr-0 mr-md-3 mb-2 mb-md-0") do
				span(class: "text-book f-s-12") {"Nadaj PIN składający się z minimum 4 cyfr, który będzie wymagany do odzyskania hasła. Dzięki niemu niepożądane osoby nie będą mogły sprawdzić czy Twój e-mail jest w naszej bazie."}
			end
			form(class: 'form-inline mr-0 mr-md-3') do
				div(class: 'input-group') do
					input(value: state.pin, type: "number", class: "form-control mb-2 mb-sm-0 #{'is-invalid' if state.pin_error}", placeholder: "Minimum 4 znaki").on :change do |e|
						mutate.pin e.target.value
						if e.target.value.size <= 3
							mutate.pin_error true
						else
							mutate.pin_error false
						end
					end
				end
			end
			button(class: "btn btn-secondary") {'Zapisz PIN'}.on(:click) do |e|
				e.prevent_default
				save_user_pin
			end
		end
	end

	def save_user_pin
		if state.pin_error
			`toast.error('PIN musi mieć co najmniej 4 znaki.')`
		else
			SaveUserPin.run(pin: state.pin).then do |response|
				`toast.dismiss(); toast.success('PIN zaktualizowany.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
			end
			.fail do |error|
				`toast.error('Przepraszamy, wystąpił błąd.')`
			end
		end
	end
end