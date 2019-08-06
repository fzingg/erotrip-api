class MobileSearchButtonStore < Hyperloop::Store
	state on_trigger: nil
	state visible: false

	def self.is_visible
		state.visible
	end

  def self.on_trigger callback
    mutate.on_trigger callback
	end

	def self.trigger
		if state.on_trigger
			state.on_trigger.call
		end
	end

	def self.show
		mutate.visible true
	end

	def self.hide
		mutate.visible false
	end
end