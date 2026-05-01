class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILERSEND_FROM_EMAIL', 'noreply@test-ywj2lpn5n6kg7oqz.mlsender.net')
  layout "mailer"
end
