FactoryBot.define do
  factory :beacon_participant do
    association :beacon
    association :user
    status { :pending }
  end
end
