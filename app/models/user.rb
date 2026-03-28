class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :google_uid, presence: true, uniqueness: true

  has_many :created_beacons,
           class_name: "Beacon",
           foreign_key: "creator_id",
           dependent: :destroy

  # beacon_participants is the join the table using this table we are tracking
  # users participation in beacons
  has_many :beacon_participants, dependent: :destroy

  # since we want to beacons in which user had participated , we are making source beacon
  has_many :joined_beacons, through: :beacon_participants, source: :beacon
end
