class SaveAlert < Hyperloop::Operation
  param reason: nil, nils: true
  param comment: nil, nils: true
  param resource_type: ''
  param resource_id: nil
  param :acting_user

  # [:content].each do |field|
  #   add_error field, :blank, "nie może być puste" do
  #     params.try(field).blank? || params.try(field).empty?
  #   end
  # end

  step do
    alert = Alert.new(
      reason: params.reason,
      comment: params.comment,
      resource_type: params.resource_type,
      resource_id: params.resource_id,
      reported_by_id: params.acting_user.try(:id) # CurrentUserStore.current_user.try(:id)
    )
    alert.save.then
  end
  step do |response|
    unless response[:success]
      raise ArgumentError, response[:saved_models].first[3]
    end
    return Alert.new(response[:saved_models].first[2])
  end
end