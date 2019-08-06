class EroNavLink < Hyperloop::Component
	include Hyperloop::Router::Mixin

	param name: nil
	param to: "provide_to_param"
	param auth: false
	param active_class: "active"
	param active_style: {}
	param exact: false, type: Boolean

	def render
		NavLink(params.to, { active_class: params.active_class, active_style: params.active_style, exact: params.exact }) do
			if params.name
				params.name
			else
				children.each do |child|
					child.render()
				end
			end
		end.on :click do |e|
			if !!params.auth && CurrentUserStore.current_user.blank?
				e.prevent_default
				ModalsService.open_modal('RegistrationModal', { callback: proc { AppRouter.push params.to } })
			end
		end
	end
end