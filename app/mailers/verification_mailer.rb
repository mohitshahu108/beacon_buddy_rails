class VerificationMailer < ApplicationMailer
  def verification_email(email, token)
    @email = email
    @token = token
    @app_name = "BeaconBuddy"
    
    mail(
      to: @email,
      subject: "Verify your email for #{@app_name}"
    )
  end
end
