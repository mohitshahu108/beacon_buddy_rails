class User < ApplicationRecord
  has_secure_password

  before_validation :set_dummy_password_for_google_users

  validates :email, presence: true, uniqueness: true
  validates :google_uid, uniqueness: true, allow_nil: true
  validates :password, presence: true, if: -> { google_uid.blank? && new_record? }
  validates :password, length: { minimum: 8 }, if: :password_required?
  validate :password_complexity, if: :password_required?

  private

  def set_dummy_password_for_google_users
    # Set a dummy password for Google users to satisfy has_secure_password
    # This password won't be used for authentication
    if google_uid.present? && password.blank?
      self.password = SecureRandom.uuid
      @dummy_password = true
    end
  end

  has_many :created_beacons,
           class_name: "Beacon",
           foreign_key: "creator_id",
           dependent: :destroy

  # beacon_participants is the join the table using this table we are tracking
  # users participation in beacons
  has_many :beacon_participants, dependent: :destroy

  # since we want to beacons in which user had participated , we are making source beacon
  has_many :joined_beacons, through: :beacon_participants, source: :beacon

  has_many :password_resets, dependent: :destroy

  public

  def generate_password_reset_token
    token = SecureRandom.urlsafe_base64(48)
    password_resets.create!(token:, expires_at: 2.hours.from_now)
    token
  end

  def valid_password_reset_token?(token)
    reset = password_resets.find_by(token:)
    return false unless reset
    return false if reset.expires_at < Time.current

    reset.destroy
    true
  end

  private

  def password_required?
    # Skip validation for dummy password set for Google users
    return false if @dummy_password
    # Only validate when password is being set/updated
    password.present?
  end

  def password_complexity
    return unless password.present?
    return if @dummy_password

    unless password.match?(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
      errors.add(:password, "must include at least one lowercase letter, one uppercase letter, one digit, and one special character")
    end
  end
end
