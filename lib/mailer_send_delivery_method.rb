# Custom Rails ActionMailer delivery method for MailerSend API
# This delivery method sends emails via MailerSend's REST API instead of SMTP

require 'mailersend-ruby'

class MailerSendDeliveryMethod
  attr_accessor :settings

  def initialize(settings = {})
    @settings = settings
    @api_key = settings[:api_key]
  end

  def deliver!(mail)
    # Create MailerSend client
    ms_client = Mailersend::Client.new(@api_key)
    
    # Initialize email class
    ms_email = Mailersend::Email.new(ms_client)

    # Extract email details from Rails mailer object
    from_email = mail.from.first
    from_name = ENV['MAILERSEND_FROM_NAME'] || 'BeaconBuddy Team'
    
    Rails.logger.info "Sending email from: #{from_email} (#{from_name})"
    Rails.logger.info "Sending email to: #{mail.to.inspect}"
    Rails.logger.info "Email subject: #{mail.subject}"
    
    # Set from
    ms_email.add_from('email' => from_email, 'name' => from_name)
    
    # Handle multiple recipients
    mail.to.each do |email|
      ms_email.add_recipients('email' => email)
    end

    # Handle CC recipients if present
    if mail.cc.present?
      mail.cc.each do |email|
        ms_email.add_cc('email' => email)
      end
    end
    
    # Handle BCC recipients if present
    if mail.bcc.present?
      mail.bcc.each do |email|
        ms_email.add_bcc('email' => email)
      end
    end

    # Set subject
    ms_email.add_subject(mail.subject)

    # Extract email content
    # For multipart emails, use mail.parts instead of mail.body.parts
    if mail.multipart?
      # Content type may include charset, so use start_with? for matching
      text_part = mail.parts.find { |p| p.content_type&.start_with?('text/plain') }
      html_part = mail.parts.find { |p| p.content_type&.start_with?('text/html') }
      text_content = text_part&.body&.decoded if text_part
      html_content = html_part&.body&.decoded if html_part
    else
      # For single part emails
      if mail.content_type&.start_with?('text/html')
        html_content = mail.body.decoded
      else
        text_content = mail.body.decoded
      end
    end

    Rails.logger.info "Extracted text content length: #{text_content&.length || 0}"
    Rails.logger.info "Extracted html content length: #{html_content&.length || 0}"
    Rails.logger.info "Mail multipart?: #{mail.multipart?}"
    Rails.logger.info "Mail parts count: #{mail.parts&.length || 0}"
    Rails.logger.info "Mail content_type: #{mail.content_type}"

    # Set content
    if html_content.present?
      ms_email.add_html(html_content)
    end
    if text_content.present?
      ms_email.add_text(text_content)
    end

    # Send email via MailerSend API
    response = ms_email.send

    # Log response for debugging
    Rails.logger.info "MailerSend API response class: #{response.class}"
    Rails.logger.info "MailerSend API response: #{response.inspect}"

    # Check if email was sent successfully
    # The API returns an HTTP::Response object, not a Hash
    if response.is_a?(HTTP::Response)
      if response.status.success?
        Rails.logger.info "Email sent successfully via MailerSend API"
        return response
      else
        Rails.logger.error "MailerSend API returned status: #{response.status}"
        Rails.logger.error "Response body: #{response.body.to_s}"
        raise "MailerSend API error: #{response.status} - #{response.body.to_s}"
      end
    elsif response.is_a?(Hash) && response['success'] == true
      return response
    else
      raise "MailerSend API error: #{response.inspect}"
    end

    response
  rescue StandardError => e
    Rails.logger.error "MailerSend delivery failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
