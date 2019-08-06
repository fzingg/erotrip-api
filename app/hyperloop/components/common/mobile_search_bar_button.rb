class MobileSearchBarButton < Hyperloop::Component
	# include VariableClassNames

	CLASSES = 'btn btn-outline-primary btn-outline-gray text-primary icon-only mobile-search-bar-button with-label more'

	param classNames: ""
	param i: nil
	param disabled: true

	param onClick: nil

	def render
		a(class: "#{CLASSES} #{params.classNames}") {
			i(class: params.i)
		}.on(:click) { params.onClick.call if !params.disabled }
	end

end