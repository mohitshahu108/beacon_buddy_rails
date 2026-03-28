FactoryBot.define do
  factory :beacon do
    title { "Test Beacon" }
    event_date { 2.days.from_now }
    max_participants { 5 }
    privacy { :personal }
    status { :active }
    association :creator, factory: :user
  end
end
