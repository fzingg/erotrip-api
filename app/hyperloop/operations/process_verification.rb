class ProcessVerification < Hyperloop::ServerOp; end
class ProcessVerification < Hyperloop::ServerOp
  param :acting_user, nils: true
  param verify: false
  param :user_id, nils: false
	param :alert_ids
	param message: ""


  step { params.verify ? verify : reject }

  step { ProcessAlerts.run({ alert_ids: params.alert_ids, accept: false, acting_user: params.acting_user }) }

  # dispatch_to { Hyperloop::Application }

  def verify
    User.find(params.user_id).verify
  end

  def reject
    User.find(params.user_id).reject_verification params.message
  end
end unless RUBY_ENGINE == 'opal'