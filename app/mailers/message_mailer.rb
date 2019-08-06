
class MessageMailer < ApplicationMailer
	def you_have_a_new_message(message, sender, receiver)
		@sender = sender
		@receiver = receiver
		@asset_host = ENV["ASSET_HOST"]

    mail(
			to: @receiver.email,
			subject: "Masz nową wiadomość!",
			template_path: 'notifications',
			template_name: 'you_have_a_new_message'
		)
	end
end