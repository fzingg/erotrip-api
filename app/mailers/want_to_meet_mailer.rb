
class WantToMeetMailer < ApplicationMailer
	def user_wants_to_meet_you(to_user, want_to_meet_user)
		@to_user = to_user
		@want_to_meet_user = want_to_meet_user
		@asset_host = ENV["ASSET_HOST"]

    mail(
			to: @to_user.email,
			subject: 'Hej, ktoś chce Cię poznać. Nie czekaj, odezwij się już taraz!',
			template_path: 'notifications',
			template_name: 'user_wants_to_meet_you'
		)
	end

	def you_have_been_matched(to_user, want_to_meet_user)
		@to_user = to_user
		@want_to_meet_user = want_to_meet_user
		@asset_host = ENV["ASSET_HOST"]

		mail(
			to: @to_user.email,
			subject: 'Nowe dopasowanie! Nie czekaj, odezwij się już taraz!',
			template_path: 'notifications',
			template_name: 'you_have_been_matched'
		)
	end
end