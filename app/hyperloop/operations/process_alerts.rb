class ProcessAlerts < Hyperloop::ServerOp; end
class ProcessAlerts < Hyperloop::ServerOp
  param :acting_user, nils: true
  param alert_ids: []
  param accept: false

  step { params.accept ? accept : reject }

  dispatch_to { Hyperloop::Application }

  def accept
    Alert.find(params.alert_ids).first.resource.destroy
  end

  def reject
    Alert.where(id: params.alert_ids).destroy_all
  end
end unless RUBY_ENGINE == 'opal'