class EroLink < Hyperloop::Component
	include Hyperloop::Router::Mixin

	param name: nil
	param to: "provide_to_param"
	param auth: false
	param disabled: false

	def render
		Link(params.to) do
			if params.name
				params.name
			else
				children.each do |child|
					child.render()
				end
			end
		end.on :click do |e|
			if params.disabled
				e.prevent_default
			elsif !!params.auth && CurrentUserStore.current_user.blank?
				e.prevent_default
				ModalsService.open_modal('RegistrationModal', { callback: proc { AppRouter.push params.to } })
			end
		end
	end
end