class DeleteUserModal < Hyperloop::Component
	include BaseModal

	state credentials: {}
	state errors: {}
	param user_id: nil
	state pin: nil

	before_unmount do
		mutate.errors['pin'] = nil
	end

	def title
		"Potwierdź usunięcie konta"
	end


	def render_modal
		div(class: 'modal-body') do
			div(class: 'row') do
				div(class: 'col') do
					FormGroup(error: state.errors['pin']) do
						h6 { 'PIN' }
						input(
							defaultValue: state.pin,
							type: "number",
							class: "form-control #{'is-invalid' if state.errors['pin']}",
							placeholder: "PIN"
							).on :key_up do |e|
								mutate.pin e.target.value
								mutate.errors['pin'] = nil
							end
						end
					end
				end
			div(class: 'modal-footer justify-content-center align-items-center', style: {justifyContent: 'center', paddingTop: 0}) do
				div(class: "d-flex justify-content-center ea-flex-1") do
					button(class: 'btn btn-secondary mr-2', type: "button") do
            			'Usuń konto'
          			end.on :click do |e|
            			e.prevent_default
						e.stop_propagation
						DeleteUser.run({user_id: CurrentUserStore.current_user.id, pin: state.pin})
							.then do |response|
								ProcessLogout.run
									.then do
									end
							`toast.error('Usunięto pomyślnie.')`
							close
						end
						.fail do |e|
							mutate.errors['pin'] = e.message
							puts "ERROR #{e}"
							puts "#{e.errors.message}"
							`toast.error('Przepraszamy! Coś poszło nie tak.')`
						end
					end
          			button(class: 'btn btn-outline-primary btn-outline-cancel text-gray', type: "button") do
            			'Anuluj'
          			end.on :click do
            			close
          			end
				end
			end
		end
	end


	def check_if_correct_pin
		state.pin.to_i == CurrentUserStore.current_user.pin
	end
end