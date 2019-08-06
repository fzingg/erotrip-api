require 'mail_interceptor'
ActionMailer::Base.register_interceptor(MailInterceptor) unless Rails.env.production?