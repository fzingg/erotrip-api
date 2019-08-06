class ModalsService < Hyperloop::Store

  state :opened_modals, scope: :class do
    {}
  end

  def self.opened_modals
    state.opened_modals
  end

  def self.open_modal(class_name, modal_params={})
    if !state.opened_modals[class_name.to_s]
      mutate.opened_modals[class_name.to_s] = { params: modal_params }
    end
    class_name
  end

  def self.close_modal(class_name)
    opened_modals = state.opened_modals
    opened_modals.delete class_name.to_s
    mutate.opened_modals opened_modals
  end

end