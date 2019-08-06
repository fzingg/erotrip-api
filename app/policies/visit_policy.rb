class VisitPolicy
	regulate_broadcast do |policy|
		policy.send_all.to(::Application)
	end
end