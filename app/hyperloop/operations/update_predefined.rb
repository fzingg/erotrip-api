class UpdatePredefined < Hyperloop::ServerOp
  param field_name: nil
  param current_terms: nil
  param :acting_user

  step do
    if params.acting_user.present?
      params.acting_user.update_attribute(params.field_name.to_sym, params.current_terms)
    end
  end
  # step do |response|
  #   unless response[:status]
  #     raise ArgumentError, response[:room].errors.messages.to_json
  #   end
  #   response[:room]
  # end
end