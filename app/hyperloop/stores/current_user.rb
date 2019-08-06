class CurrentUserStore < Hyperloop::Store
  state current_user: nil
	state current_user_id: nil

	state on_load_callbacks: []
  # , initialize: :init_current_user

  def self.current_user
    state.current_user
  end

  def self.current_user_id
    state.current_user_id
  end

  def self.current_user!(new_val)
		mutate.current_user new_val
  end

  def self.update_session_connection!(old_session, new_session)
    puts "\n\n\n\n update_session_connection::: \n old_session --> #{old_session} \n new_session --> #{new_session}"
    # Hyperloop.disconnect(old_session)
    Hyperloop.connect(new_session)
    # Hyperloop.connect_session
  end

  def self.current_user_id!(new_val)
    mutate.current_user_id new_val
    self.init_current_user
  end

  def self.init_current_user
    if state.current_user_id.present?
      puts "INITIALIZING current_user based on id: #{state.current_user_id}"
			mutate.current_user User.find(state.current_user_id)
      User.find(state.current_user_id).load(:predefined_users, :predefined_trips, :predefined_hotline, :lon, :lat).then do |data|
			  CurrentUserStore.load_current_user
      end
    else
      puts "NO CURRENT USER"
      mutate.current_user nil
    end
	end

	def self.load_current_user
		# At this moment current user is ready to work with it using Hyperloop::Model.load
		if state.on_load_callbacks.try(:size).try(:>, 0)
			state.on_load_callbacks.each { |callback| callback.call(true) }
		end
	end

	def self.on_current_user_load callback
		if !state.on_load_callbacks
			mutate.on_load_callbacks []
			mutate.on_load_callbacks (state.on_load_callbacks << callback)
		else
			mutate.on_load_callbacks (state.on_load_callbacks << callback)
		end

		if CurrentUserStore.current_user.present?
			callback.call()
		end
	end

  receives Hyperloop::Application::Boot do
    if state.current_user_id != Hyperloop::Application.acting_user_id.try(:to_i)
      mutate.current_user_id Hyperloop::Application.acting_user_id.try(:to_i)
    end
  end

  # receives ProcessRegistration do
  #   puts "RECEIVED ProcessRegistration"
  #   puts params
  # end

end