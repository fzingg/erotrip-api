class ProfileNotFound < Hyperloop::Router::Component
	before_mount do
		"mounting profile not found"
	end

	def render
		div(class: 'row') do
			div(class: 'col-12 col-xl-9 ml-xl-auto main-content profile profile-not-found') do

				# HotlineCarousel()

				div(class: "pnf-outer-wrapper") do
					div(class: "pnf-inner-wrapper") do

						div do
							img(src: '/assets/user-blank.png')
						end

						div(class: "pnf-text-wrapper")  do
							div(class: "pnf-text") do
								h4(class: "text-book") do
									span {'Niestety, taki użytkownik '}
									span(class: "text-secondary") {'nie istnieje!'}
								end
							end

							button(class: "btn btn-secondary mt-2 mb-3 mt-md-4 mb-md-0") do
								span {'Wróć do listy użytkowników'}
							end.on :click do
								AppRouter.push '/users'
							end
						end

					end
				end
			end
		end
	end
end


