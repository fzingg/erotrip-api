class SidebarStore < Hyperloop::Store

  state is_open: false, scope: :class

  def self.is_open
    state.is_open
  end

  def self.set_state(val)
    mutate.is_open val
  end
end