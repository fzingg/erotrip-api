class MailInterceptor
  def self.delivering_email(message)
    if ENV['DELIVER_MAILS_TO'].present?
      message.subject = "#{message.to} - #{message.subject}"
      message.to = ENV['DELIVER_MAILS_TO']
    end
  end
end
