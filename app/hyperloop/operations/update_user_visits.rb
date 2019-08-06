class UpdateUserVisits < Hyperloop::ControllerOp; end
class UpdateUserVisits < Hyperloop::ControllerOp
	# outbound :response
	param :visit, nils: false


	step do
		if acting_user.present? && ['trips', 'peepers', 'users'].include?(params.visit)
			update_hash = {}
			acting_user["last_#{params.visit}_visit_at"] = DateTime.now
			acting_user.save
		end
	end

end unless RUBY_ENGINE == 'opal'