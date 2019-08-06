class AnonymousModal < Hyperloop::Component
  include BaseModal

  def title
    'Tryb anonimowy'
  end

  def render_modal
    span do
      div(class: 'modal-body text-center') do
        h5 { modal_header }

        div(class: 'mt-4 mb-4 flex justify-content-center align-items-center') do
          button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125") do
            'Tak'
          end.on :click do
            set_anonymous_mode !CurrentUserStore.current_user.is_private
          end
          button(class: "ml-2 mr-2 btn btn-ouline-gray-to-primary btn-round-125") do
            'Nie'
          end.on :click do
						close
          end
        end
      end
    end
	end

	def modal_header
		 if CurrentUserStore.current_user
			if CurrentUserStore.current_user.is_private
				"Czy chcesz wyłączyć tryb anonimowy?"
			else
				"Czy chcesz przejść w tryb anonimowy?"
			end
		 else
			""
		 end
	end

	def set_anonymous_mode anonymous
		SetAnonymousMode.run(
			is_private: anonymous,
		)
		.then do |response|
			`toast.dismiss(); toast.success('Operacja zakończona pomyślnie!', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
			close
		end
		.fail do |e|
			`toast.error('Przepraszamy, wystąpił błąd!')`
			close
		end
  end

end