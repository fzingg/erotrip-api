class HotlineCarousel < Hyperloop::Router::Component
	state current_page: 1
	state per_page: 1
	state created_at_humanized: nil
	state is_loaded: false
	state :hotline_scope

	before_mount do
		mutate.current_page 1
		mutate.per_page 1
		mutate.hotline_scope Hotline.new_first.created_after((today - 48.hours).to_s)
		if state.hotline_scope[state.current_page - 1].present? && state.hotline_scope[state.current_page - 1].created_at.present?
			set_humanized_created_at(state.hotline_scope[state.current_page - 1].created_at)
			HotlineTimeStore.add_callback proc { set_humanized_created_at(state.hotline_scope[state.current_page - 1].created_at) }
		end
	end


	before_unmount do
		@interval.abort if @interval.present?
	end


	def change_hotline
		next_hotline if state.is_loaded
	end

	def should_be_hidden
		location.pathname.start_with?('/profile') || (location.pathname.start_with?('/groups/') && location.pathname.length > 8)
	end

  def today
    now = Time.now
    Time.new(now.year, now.month, now.day, 0, 0, 0)
  end

	def render
		div(class: "row #{'is-hidden' if should_be_hidden}") do
      div(class: 'col-12 col-xl-9 ml-xl-auto') do

				mutate.is_loaded true if !state.is_loaded && state.hotline_scope.loaded?
				if state.hotline_scope.loaded? && state.hotline_scope.present?

					# if state.created_at_humanized.blank? && state.hotline_scope[state.current_page - 1].present? && state.hotline_scope[state.current_page - 1].created_at.present?
					# 	set_humanized_created_at(state.hotline_scope[state.current_page - 1].created_at)
					# end

					if Commons.is_initially_loaded
						@interval = Browser::Window.every(5.0) { change_hotline } if @interval.blank?
					end

				end


				if (state.hotline_scope.try(:count) || 1) > 0
					div(class: "hotline-card-wrapper index-wrapper") do
						div(class: 'patch')
						div(class: "hotline-mobile-photo-container") do
							img(src: state.hotline_scope[state.current_page - 1].try(:avatar_url))

							unless !state.hotline_scope[state.current_page - 1].try(:user).try(:is_verified)
								i(class: 'ero-checkmark icon full-bg is-verified f-s-25')
							end
						end

						div(class: "hotline-card #{'pointer' if state.hotline_scope[state.current_page - 1].try(:user_id) != CurrentUserStore.current_user_id}") do
							img(src: state.hotline_scope[state.current_page - 1].try(:avatar_url), class: "hotline-img")

							div(class: "hotline-card-inner") do
								div(class: "hotline-descriptor-city") do
									UserDescriptor( user: state.hotline_scope[state.current_page - 1].try(:user), show_status: true, show_verification: true, show_two_lined: false, mode: 'hotline')
									div(class: 'hotline-city') do
										span(class: 'text-gray text-book') { state.hotline_scope[state.current_page - 1].try(:city) }
									end
								end
								div(class: 'hotline-time') do
									if state.created_at_humanized.present?
										span(class: 'text-gray mr-1') {"#{state.created_at_humanized['prefix']}#{state.created_at_humanized['datetime']}"}
									end
									span(class: 'text-gray') { state.hotline_scope[state.current_page - 1].try(:city) }
								end

								p(class: 'hotline-text text-book text-gray-semidark mb-0 d-block d-md-none') { (state.hotline_scope[state.current_page - 1].try(:content) || '...')[0..60] + "#{(state.hotline_scope[state.current_page - 1].try(:content).try(:size) || 0) > 60 ? '...' : ''}"}

								p(class: 'hotline-text text-book text-gray-semidark mb-0 d-none d-md-block') { (state.hotline_scope[state.current_page - 1].try(:content) || '...')}

								div(class: 'hotline-card-labels') do
									span(class: 'hotline-text') {'Hotline'}
									# span(class: 'text-gray-light hotline-label') do
									# 	span(class: 'hotline-text mr-2') { 'Hotline' }
									# end.on :click do |e|
									# 	e.prevent_default
									# 	e.stop_propagation
									# 	AppRouter.push("/hotline")
									# end
									span(class: 'f-s-14') do
										span(class: 'current-page f-s-14') { state.current_page.to_s }
										span() {'/'}
										span(class: 'all-pages f-s-14') { (state.hotline_scope.loaded? && state.hotline_scope.present? ? state.hotline_scope.count.try(:to_s) : '...') }
									end
								end
							end

							div(class: 'hotline-carousel-buttons') do
								div(class: 'text-gray-light hotline-label') do
									span(class: 'hotline-text mr-2') { 'Hotline' }
								end.on :click do |e|
									e.prevent_default
									e.stop_propagation
									AppRouter.push("/hotline")
								end

								button(class: 'btn btn-container text-white primary-border secondary-bg mb-2 hotline-add', type: 'button') do
									i(class: 'ero-cross f-s-18')
								end.on(:click) do |e|
									e.prevent_default
									e.stop_propagation
									add_hotline
								end

								div(class: 'hotline-nav') do
									div(class: 'hotline-counter') do
										span(class: 'current-page') { state.current_page.to_s }
										span() {'/'}
										span(class: 'all-pages') { (state.hotline_scope.loaded? && state.hotline_scope.present? ? state.hotline_scope.count.try(:to_s) : '...') }
									end

									button(class: "btn btn-sm btn-container white-bg btn-prev", type: "button") do
										i(class: 'ero-chevron-left-rounded f-s-16')
									end.on(:click) do |e|
										e.prevent_default
										e.stop_propagation
										if @interval
											@interval.abort
											@interval = Browser::Window.every(5.0) { change_hotline }
										end
										prev_hotline
									end
									# button(class: "btn btn-sm btn-container white-bg btn-next", type: "button") do
									# 	i(class: 'ero-chevron-right-rounded f-s-12')
									# end.on(:click) do
									# 	@interval.abort if @interval
									# 	next_hotline
									# end
								end
							end
						end.on(:click) do |e|
							go_to_profile(state.hotline_scope[state.current_page - 1], e)
						end
					end
				else
				  no_hotlines
				end
			end
		end
	end

	def no_hotlines
		div(class: "hotline-card-wrapper index-wrapper no-hotlines") do
			div(class: 'patch')

			div(class: "hotline-card") do

				div(class: "no-hotlines-card-inner") do
					i(class: 'ero-hotline mr-2')
					div(class: "d-flex flex-column flex-md-row align-items-center justify-content-center") do
						span()do
							span(class: 'text-gray') { "Dodaj " }
							span(class: 'text-secondary ml-2') {'hotline'}
							span(class: 'text-gray mr-2') { ", " }
						end
						span()do
							span(class: 'text-gray') { "bądź pierwszy!" }
						end
					end
				end

				div(class: 'hotline-carousel-buttons') do
					button(class: 'btn btn-container text-white primary-border secondary-bg mb-2 hotline-add', type: 'button') do
						i(class: 'ero-cross f-s-18')
					end.on(:click) do |e|
						e.prevent_default
						e.stop_propagation
						add_hotline
					end
				end
			end

		end
	end

	def go_to_profile hotline, event=nil
		if event
			event.prevent_default
			event.stop_propagation
		end
		if hotline.try(:user_id) != CurrentUserStore.current_user_id
			if !hotline.try(:is_anonymous) && hotline.try(:user).present?
				AppRouter.push("/profile/#{hotline.user.id}?hot=#{hotline.try(:id)}")
			else
				open_messenger hotline
			end
		end
	end

	def open_messenger hotline, event=nil
		if event
			event.prevent_default
			event.stop_propagation
		end
		if CurrentUserStore.current_user.blank?
			ModalsService.open_modal('RegistrationModal', { callback: proc { do_open_messenger(hotline) } })
		else
			do_open_messenger hotline
		end
	end

	def do_open_messenger hotline
		mutate.blocking true
		GetRoomUserForContextAndJoin.run({ context_type: 'Hotline', context_id: hotline.id })
		.then do |room_user|
			mutate.blocking false
			ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static', initial_room_user_id: room_user.try(:id), initial_message: 'Hej, chętnie Cię poznam ;)' })
		end.catch do |e|
			mutate.blocking false
		end
	end

	# old
	def can_show_next?
		(state.current_page < state.hotline_scope.try(:count)) && (state.hotline_scope.try(:count) != 0)
	end

	def can_show_prev?
		state.current_page > 1
	end

	def next_hotline
		if can_show_next?
			mutate.current_page state.current_page + 1
		else
			mutate.current_page 1
		end
		HotlineTimeStore.force_callbacks
		# set_humanized_created_at
		# mutate.user(User.find state.hotline_scope[state.current_page].user_id)
	end

	def prev_hotline
		if can_show_prev?
			mutate.current_page state.current_page - 1
		else
			mutate.current_page state.hotline_scope.try(:count)
		end
		HotlineTimeStore.force_callbacks
		# set_humanized_created_at
		# mutate.user(User.find state.hotline_scope[state.current_page].user_id)
	end

	def add_hotline
		ModalsService.open_modal('HotlineNewModal', { size_class: 'modal-lg' })
	end


	def get_created_at_humanized(date)
		if (date.present?)
			# date = Time.parse(date.to_s)
			# `var newDate = new Date(#{date.to_s})
			# var returnedValue = null;
			# if (new Date().toDateString() === newDate.toDateString()) {
			# 	var minutes_ago = Math.abs(Math.round( (newDate - new Date()) / 60000 ))
			# 	if (minutes_ago < 60) {
			# 	 	returnedValue = { prefix: "", datetime: minutes_ago + " min temu" }
			# 	} else {
			#  		returnedValue = { prefix: "", datetime: #{date.strftime('%H:%M')} }
			# 	}
			# } else if (newDate.toDateString() == new Date(new Date().setDate(new Date().getDate() -1 )).toDateString()) {
			# 	returnedValue =	{ prefix: "Wczoraj, ", datetime: #{date.strftime('%H:%M')} }
			# } else {
			# 	returnedValue = { prefix: "", datetime: #{date.strftime('%d-%m-%y %H:%M')} }
			# }`
			# Native(`returnedValue`)

			# new_date = Time.parse(date.to_s)
			new_date = Time.parse(date) #LukasFix
	    result = nil
	    if new_date.strftime('%d.%m.%Y') == (Time.now - 1.days).strftime('%d.%m.%Y')
	      result = { prefix: "Wczoraj, ", datetime: new_date.strftime('%H:%M ') }
	    elsif new_date.strftime('%d.%m.%Y') == (Time.now).strftime('%d.%m.%Y')
	    	minutes_ago = ((Time.now.to_i - new_date.to_i) / 60).to_i.abs
	    	if minutes_ago < 60
	    		result = { prefix: "", datetime: "#{minutes_ago} min temu" }
	    	else
	      	result = { prefix: "Dziś, ", datetime: new_date.strftime('%H:%M ') }
	      end

	    elsif new_date.strftime('%d.%m.%Y') == (Time.now + 1.days).strftime('%d.%m.%Y')
	      result = { prefix: "Jutro, ", datetime: new_date.strftime('%H:%M ') }
	    else
	    	months = ['', 'sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru']
	      result = { prefix: '', datetime: "#{new_date.strftime('%d')} #{months[new_date.month]} #{new_date.strftime('%Y %H:%M ')}" }
	    end
	    result

		end

	end

	def set_humanized_created_at(date)
		x = get_created_at_humanized(date)
		hash = { prefix: x.try(:[], :prefix), datetime: x.try(:[], :datetime) }
		# puts "CREATED AT HUMANIZED, #{hash}"
		mutate.created_at_humanized hash
	end

end