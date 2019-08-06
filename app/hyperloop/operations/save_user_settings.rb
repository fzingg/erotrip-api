class SaveUserSettings < Hyperloop::ControllerOp
  param :user_id
  param attr: ''
  param obj: {}

  step { @user = User.find(params.user_id)  }
  step { @user.update_attribute(params.attr.to_sym, params.obj)  }
  # step do |response|
  # end

end