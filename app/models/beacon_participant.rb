class BeaconParticipant < ApplicationRecord
  belongs_to :beacon
  belongs_to :user

  enum status: { pending: 0, joined: 1, rejected: 2, left: 3 }

  validates :user_id, uniqueness: { scope: :beacon_id } # prevent duplicate requests
end
