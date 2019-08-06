
class VisitMailer < ApplicationMailer
	def user_visited_your_profile(visit)
		@visitor = visit.visitor
		@asset_host = ENV["ASSET_HOST"]

    mail(
			to: visit.visitee.email,
			subject: "Masz nowego gościa!",
			template_path: 'notifications',
			template_name: 'user_visited_your_profile'
		)
	end
end