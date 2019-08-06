class CountBadge < Hyperloop::Component
	param :scope

	def render
		if params.scope && !params.scope.loading? && params.scope.count > 0
				span(class: "badge badge-secondary badge-sidebar mr-2 ml-2") { (params.scope.count || 0).to_i > 99 ? '+99' : params.scope.count.try(:to_s) }
		else
				''
		end
	end
end