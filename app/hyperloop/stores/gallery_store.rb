class GalleryStore < Hyperloop::Store

  state is_open: false, scope: :class

  def self.is_open
    state.is_open
  end

  def self.toggle_open(val)
    mutate.is_open val
  end
end