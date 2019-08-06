class AuthSettings < Hyperloop::Component
	param :user
	state current_tab: 'password'

	def render
		div(class: 'auth-settings-wrapper mt-5') do
			div(class: 'menu d-flex') do
				div(class: "item #{'active' if state.current_tab == 'password'}") { "Zmień hasło" }.on(:click) { |e| mutate.current_tab 'password' }
				div(class: "item #{'active' if state.current_tab == 'email'}") { "Zmień email" }.on(:click) { |e| mutate.current_tab 'email' }
				div(class: "item #{'active' if state.current_tab == 'pin'}") { "Zmień PIN" }.on(:click) { |e| mutate.current_tab 'pin' } if params.user.try(:pin)
			end

			if state.current_tab == "pin" && params.user.try(:pin)
				SettingsPin(user: state.user)
			elsif state.current_tab == "password"
				SettingsPassword(user: state.user)
			elsif state.current_tab == "email"
				SettingsEmail(user: state.user)
			end
		end
	end
end