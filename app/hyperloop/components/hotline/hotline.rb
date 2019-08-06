class HotlineHotline < Hyperloop::Component

	param :hotline
	param display_buttons: true, nils: true
	param :about_to_remove
	param :on_remove_init
	state :blocking
	state :created_at_humanized


	def trigger_formatted_dates_update
		if params.hotline.present? && params.hotline.created_at.present?
			set_humanized_created_at params.hotline.created_at
		end
	end


	before_mount do
		mutate.blocking false if state.blocking != false
		mutate.created_at_humanized nil
		trigger_formatted_dates_update
	end

	after_mount do
		HotlineTimeStore.add_callback proc { set_humanized_created_at }
	end

	before_receive_props do |new|
		if new[:hotline][:id] != params.hotline.id
			mutate.created_at_humanized nil
			Hotline.find(new[:hotline][:id]).load(:created_at).then do |l|
				set_humanized_created_at l
			end
		end
	end

	def get_created_at_humanized(date = params.hotline.created_at)
		#  if React::IsomorphicHelpers.on_opal_client?
		# `var newDate = new Date(#{date.to_s})
		# var result = null;
		# if (new Date().toDateString() === newDate.toDateString()) {
		# 	var minutes_ago = Math.abs(Math.round( (newDate - new Date()) / 60000 ))
		# 	if (minutes_ago < 60) {
		# 	 	result = { prefix: "", datetime: minutes_ago + " min temu" }
		# 	} else {
		#  		result = { prefix: "", datetime: #{date.strftime('%H:%M')} }
		# 	}
		# } else if (newDate.toDateString() == new Date(new Date().setDate(new Date().getDate() -1 )).toDateString()) {
		# 	result =	{ prefix: "Wczoraj, ", datetime: #{date.strftime('%H:%M')} }
		# } else {
		# 	result = { prefix: '', datetime: #{date.strftime('%d')} + ' ' + newDate.toLocaleString('pl-PL', { month: "short" }) + ' ' + #{date.strftime('%Y %H:%M ')} }
		# }`
		# Native(`result`)
		#  else
		#  end
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

	def set_humanized_created_at(date = params.hotline.created_at)
		x = get_created_at_humanized date
		hash = { prefix: x[:prefix], datetime: x[:datetime] }
		mutate.created_at_humanized hash
	end

	def render
		BlockUi(tag: "div", blocking: state.blocking) do
			div(class: "hotline-card-wrapper #{'dark-overlay' if !!params.about_to_remove}") do
				div(class: "remove-wrapper #{'shown' if !!params.about_to_remove }") do
					button(class: "btn icon-only btn-container text-white white-border white-bg remove-btn", type: "button") do
						i(class: 'ero-trash f-s-22 text-secondary')
					end.on :click do |e|
						confirm_deletion params.hotline, e
					end
					span(class: "text-white f-s-18") {'Usuń hotline'}
				end

				div(class: "hotline-mobile-photo-container") do
					img(src: params.hotline.try(:avatar_url)).on :click do |e|
						go_to_profile params.hotline, e
					end

					unless !params.try(:hotline).try(:user).try(:is_verified)
						i(class: 'ero-checkmark icon full-bg')
					end
				end

				div(class: "hotline-card gray #{'pointer' if params.hotline.try(:user_id) != CurrentUserStore.current_user_id}") do
					img(class: "hotline-img", src: params.hotline.try(:avatar_url))

					div(class: "hotline-card-inner") do
						div(class: "hotline-descriptor-city") do
							UserDescriptor( user: params.hotline.try(:user), show_status: true, show_verification: true, show_two_lined: false, mode: 'hotline')
							div(class: 'hotline-city') do
								span(class: 'text-gray text-book') { params.hotline.try(:city) }
							end
						end
						div(class: 'hotline-time') do
							span(class: 'text-gray') { state.created_at_humanized.present? ? "#{state.created_at_humanized['prefix']}#{state.created_at_humanized['datetime']}" : '' }
							span(class: 'text-gray ml-1') { params.hotline.try(:city) }
						end

						p(class: 'hotline-text mb-0 text-book') { params.hotline.try(:content) }
					end

					if params.display_buttons
						div(class: 'hotline-action-buttons') do
							if params.hotline.try(:user_id) != CurrentUserStore.current_user_id
								button(class: 'btn icon-only btn-container text-white white-border secondary-bg', type: "button") do
									i(class: 'ero-messages f-s-18')
								end.on :click do |e|
									open_messenger params.hotline, e
								end

								button(class: 'btn icon-only btn-container text-gray white-border lightest-gray-bg btn-warning', type: "button") do
									i(class: 'ero-alert-circle-outline')
								end.on(:click) { |e| alert_hotline params.hotline, e }
							else
								button(class: 'btn icon-only btn-container text-white white-border secondary-bg', type: "button") do
									i(class: 'ero-pencil f-s-18')
								end.on :click do |e|
									edit_hotline params.hotline, e
								end

								button(class: 'btn icon-only btn-container text-gray white-border lightest-gray-bg btn-warning', type: "button") do
									i(class: 'ero-trash')
								end.on(:click) { |e| remove_hotline params.hotline, e }
							end
						end
					end
				end.on :click do |e|
					go_to_profile params.hotline e
				end

			end
		end
	end

	def go_to_profile hotline, event=nil
		if event
			event.prevent_default
			event.stop_propagation
		end
		if params.hotline.try(:user_id) != CurrentUserStore.current_user_id
			if !params.hotline.try(:is_anonymous) && params.hotline.try(:user).present? && !params.hotline.try(:user).try(:is_private)
				AppRouter.push("/profile/#{hotline.user.id}?hot=#{hotline.try(:id)}")
			else
				open_messenger params.hotline
			end
		end
	end

	# def hotline_avatar_url
	# 	if params.hotline.try(:user).try(:avatar_url) && params.hotline.is_anonymous.loaded?
	# 		# && CurrentUserStore.current_user.id != params.hotline.user_id
	# 		if params.hotline.is_anonymous
	# 			params.hotline.try(:user).try(:avatar_url, "blurred")
	# 		else
	# 			params.hotline.try(:user).try(:avatar_url)
	# 		end
	# 	else
	# 		'/assets/user-blank.png'
	# 	end
	# end

	def edit_hotline hotline, event=nil
		if event
			event.prevent_default
			event.stop_propagation
		end
		ModalsService.open_modal('HotlineEditModal', { hotline: hotline, size_class: 'modal-lg' })
	end

	def remove_hotline hotline, event=nil
		if event
			event.prevent_default
			event.stop_propagation
		end
		params.on_remove_init.call(hotline.try(:id))
	end

	def confirm_deletion hotline, event=nil
		if event
			event.prevent_default
			event.stop_propagation
		end
		RemoveHotline.run(id: hotline.try(:id)).then do |data|
			`toast.dismiss(); toast.success('Usunęliśmy hotline.', { hideProgressBar: true, pauseOnHover: false, autoClose: 1800 })`
		end.fail do |err|
			`toast.dismiss(); toast.error('Nie udało się usunąć hotline.')`
		end
	end

	def alert_hotline hotline, event=nil
		if event
			event.prevent_default
			event.stop_propagation
		end
		if CurrentUserStore.current_user.blank?
			ModalsService.open_modal('RegistrationModal', { callback: proc { do_alert_hotline(hotline) } })
		else
			do_alert_hotline hotline
		end
	end

	def do_alert_hotline hotline
		ModalsService.open_modal('HotlineAlert', { size_class: 'modal-md', resource_id: hotline.try(:id), resource_type: 'Hotline' })
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
			puts "room_user #{room_user}"
			mutate.blocking false
			# `console.log('we have room_user', room_user.context_id, room_user.id, room_user)`
			ModalsService.open_modal('Messenger', { size_class: 'modal-lg messenger-modal', backdrop: 'static', initial_room_user_id: room_user.try(:id), initial_message: 'Hej, chętnie Cię poznam ;)' })
		end.catch do |e|
			mutate.blocking false
			puts "ERROR, #{e.inspect}"
		end
	end

end