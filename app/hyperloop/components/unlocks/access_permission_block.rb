class AccessPermissionBlock < Hyperloop::Component

	param :permission
	state blocking: false

	def render
		tr(class: "access-permission-block") do
			td(class: "requested-by-wrapper") do
				div(class: "requested-by") do
					div(class: "requested-by-avatar-wrapper") do
						img(class: "requested-by-avatar img-fluid", src: params.permission.permitted.avatar_url)
					end
					div(class: "requested-by-user") do
						UserDescriptor(user: params.permission.permitted)
					end
				end
			end
			td(class: "requested-access-wrapper") do
				div(class: "requested-access") do
					div(class: "option") do
						div(class: "type") { "profilu" }
						div(class: 'btn-group', role: "group") do
							button(class: "btn btn-outline-primary btn-outline-gray text-gray #{params.permission.profile_granted ? 'active' : ''}", type: "button") do
								'Tak'
							end.on(:click) do |e|
								set_access("profile", true)
							end
							button(class: "btn btn-outline-primary btn-outline-gray text-gray #{!params.permission.profile_granted ? 'active' : ''}", type: "button") do
								'Nie'
							end.on(:click) do |e|
								set_access("profile", false)
							end
						end
					end
					div(class: "option") do
						div(class: "type") { "galerii prywatnej" }
						div(class: 'btn-group', role: "group") do
							button(class: "btn btn-outline-primary btn-outline-gray text-gray #{!params.permission.profile_granted ? 'disabled' : ''} #{params.permission.private_photos_granted ? 'active' : ''}", type: "button") do
								'Tak'
							end.on(:click) do |e|
								if params.permission.profile_granted
									set_access("private_photos", true)
								else
									e.prevent_default
								end
							end
							button(class: "btn btn-outline-primary btn-outline-gray text-gray #{!params.permission.profile_granted ? 'disabled' : ''} #{!params.permission.private_photos_granted ? 'active' : ''}", type: "button") do
								'Nie'
							end.on(:click) do |e|
								if params.permission.profile_granted
									set_access("private_photos", false)
								else
									e.prevent_default
								end
							end
						end
					end
				end
			end
			td(class: "delete-button-wrapper") do
				div(class: "delete-button") do
					button("data-tip": "", "data-for": "delete-btn-#{params.permission.id.to_s}", class: "btn icon-only btn-no-focus delete", type: "button") do
						i(class: 'ero-trash')
					end.on(:click) do |e|
						e.prevent_default
						e.stop_propagation
						remove
					end
				end
				ReactTooltip("id": "delete-btn-#{params.permission.id.to_s}", class: 'customeTheme', "place": "bottom", "effect": "solid") do
					div { "Odrzuć" }
				end
			end
		end
	end

	def set_access type, perm_state
		if !state.blocking
			mutate.blocking true
			ToggleAccess.run(permitted_id: params.permission.permitted.id, type: type, perm_state: perm_state)
			.then do |response|
				mutate.blocking false
				`toast.dismiss(); toast.success("Dostęp udzielony.", { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
			end
			.fail do |error|
				mutate.blocking false
				`toast.error("Przepraszamy, wystąpił błąd.")`
			end
		end
	end

	def remove
		if !state.blocking
			mutate.blocking true
			RemoveAccessPermission.run(permitted_id: params.permission.permitted.id)
			.then do |response|
				mutate.blocking false
				`toast.dismiss(); toast.success("Prośba została odrzucona.", { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
			end
			.fail do |error|
				mutate.blocking false
				`toast.error("Przepraszamy, wystąpił błąd.")`
			end
		end
	end
end