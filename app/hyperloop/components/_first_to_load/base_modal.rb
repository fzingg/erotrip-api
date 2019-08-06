module BaseModal

  def self.included(base)
    base.param callback: nil
    base.param size_class: ''
    base.param backdrop: 'static'
    base.collect_other_params_as :attributes

    base.state blocking: false

    base.after_mount do
      mutate.blocking(false)
      if params.backdrop == 'false' || params.backdrop == false
        `$("#" + #{self.id()}).modal({backdrop: false, show: true, keyboard: false})`
      else
        `$("#" + #{self.id()}).modal({backdrop: 'static', show: true, keyboard: false})`
      end
    end

    base.render do
      div(id: id, class: "modal fadeable", role: "dialog", tabIndex: "-1", "data-keyboard" => "false") do
        div(class: "modal-dialog #{params.size_class}", role: "document") do
          div(class: 'modal-content') do
            div(class: 'modal-header') do
              h5(class: 'modal-title') { title }
              button(class: 'close', type: "button") do
                span do
                  i(class: 'ero-cross f-s-15 d-inline-block rotated-45deg')
                end
              end.on :click do
                close
              end
            end
            render_modal
          end
        end
      end
    end
  end

  def close
    `$("#" + #{self.id()}).modal('hide')`
    ModalsService.close_modal(self.class.to_s)
  end

  def id
    self.class.to_s.underscore.gsub('_', '-')
  end

  def title
    'DODAJ METODĘ "title" W MODALU'
  end

  def render_modal
    div(class: 'modal-body') do
      div {'DODAJ METODĘ render_modal zawierającą przynajmniej div\'a z klasą "modal-body"'}
      div { 'Możesz przekazać przy otwieraniu modala parametr "size_class" z wartościami "modal-lg" itp' }
    end
  end

end