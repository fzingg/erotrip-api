class HotlineTimeStore < Hyperloop::Store
	state on_load_callbacks: []
  state intitialized: false
	state midnight_timer: nil
  def self.init
    if RUBY_ENGINE == 'opal' && !state.intitialized
        `setInterval(function(){ #{self.init_all_callbacks} }, 60000);`
				mutate.intitialized true
				self.set_midnight_timer
		end
	end

  def self.add_callback callback
		if !state.on_load_callbacks
			mutate.on_load_callbacks []
			mutate.on_load_callbacks (state.on_load_callbacks << callback)
		else
			mutate.on_load_callbacks (state.on_load_callbacks << callback)
		end
  end

  def self.force_callbacks
    self.init_all_callbacks
	end

  def self.init_all_callbacks
		if state.on_load_callbacks.try(:size).try(:>, 0)
			state.on_load_callbacks.each { |callback| callback.call(true) }
		end
	end


	def self.restart_midnight_timer
		self.clear_midnight_timer
		self.set_midnight_timer
	end

	def self.set_midnight_timer
	`var midnightDate = new Date();
		midnightDate.setHours(24,0,0,0);
		var diff = midnightDate.getTime() - (new Date()).getTime();
		var interval = setTimeout(function(){
			console.log('zmiana');
		#{self.force_callbacks}
		#{self.restart_midnight_timer}
		}, diff + 2500);`
		mutate.midnight_timer 'interval'
	end

	def self.clear_midnight_timer
		`clearTimeout(#{state.midnight_timer})` unless state.midnight_timer.nil?
		mutate.midnight_timer nil
	end




end