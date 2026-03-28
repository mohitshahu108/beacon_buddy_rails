class Beacon < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :beacon_participants, dependent: :destroy
  has_many :participants, through: :beacon_participants, source: :user

  enum :category, {
    movie: 0,
    sports: 1,
    park: 2,
    food: 3,
    other: 4
  }

  enum :beacon_type, {
    two_person: 0,
    group: 1
  }, prefix: :type

  enum :join_policy, {
    open: 0,
    personal: 1,
    filtered: 2
  }

  enum :status, {
    draft: 0,
    published: 1,
    active: 2,
    completed: 3,
    cancelled: 4,
    archived: 5
  }

  validates :title, presence: true
  validates :category, presence: true
  validates :beacon_type, presence: true
  validates :join_policy, presence: true
  validates :event_time, presence: true
  validates :max_participants, numericality: { greater_than: 0 }

  def joined_count
    beacon_participants.where(status: :joined).count
  end
end
