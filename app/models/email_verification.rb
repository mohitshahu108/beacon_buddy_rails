class EmailVerification < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :verification_token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  def expired?
    expires_at < Time.current
  end

  def self.generate_for(email)
    # Delete any existing verification for this email
    where(email: email).destroy_all

    # Generate new verification token
    token = SecureRandom.urlsafe_base64(48)
    create!(
      email: email,
      verification_token: token,
      expires_at: 2.hours.from_now,
      verified: false
    )
    token
  end

  def self.verify(email, token)
    verification = find_by(email: email, verification_token: token)
    return false unless verification
    return false if verification.expired?

    verification.update(verified: true)
    true
  end

  def self.verified?(email, token)
    verification = find_by(email: email, verification_token: token)
    return false unless verification
    return false if verification.expired?
    verification.verified?
  end
end
