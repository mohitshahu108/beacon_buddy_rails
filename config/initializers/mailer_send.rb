# MailerSend API Configuration
# This initializer sets up the MailerSend client for email delivery via API

require 'mailersend-ruby'
require_relative '../../lib/mailer_send_delivery_method'

Rails.application.config.after_initialize do
  # Register custom delivery method with API key
  ActionMailer::Base.add_delivery_method :mailer_send, MailerSendDeliveryMethod,
    api_key: ENV['MAILERSEND_API_KEY']
end
