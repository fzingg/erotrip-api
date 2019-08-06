class RemoveHotline < Hyperloop::Operation
  param id: nil

  step do
    hotline = Hotline.find(params.id)
    hotline.destroy.then
  end
  step do |response|
    unless response[:success]
      hotline.revert
      raise ArgumentError, response[:saved_models].first[3]
    end
    return {}
  end
end