class Notify < Hyperloop::ServerOp
	param :to_who
	param :kind
  param :additional_data, nils: true

	step do
    puts 'RUNNING NOTIFY OPERATION!!!'
		{
			to_who: params.to_who,
			kind: params.kind,
      additional_data: params.additional_data
		}
	end

end