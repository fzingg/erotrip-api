class RequestAccessButton < Hyperloop::Component

		param :owner

		def render
			button(class: "btn btn-secondary btn-no-focus icon-only icon-only-bigger button-request-access", type: "button") do
				i(class: 'ero-locker f-s-25')
			end.on :click do |e|
				e.prevent_default
				e.stop_propagation
				request_profile_access
			end
		end

		def request_profile_access
			RequestAccess.run(owner_id: params.owner.id, type: "profile")
			.then do |response|
				`toast.dismiss(); toast.success("Prośba została wysłana.", { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
			end
			.fail do |error|
				`toast.error("Przepraszamy, wystąpił błąd.")`
			end
		end
	end