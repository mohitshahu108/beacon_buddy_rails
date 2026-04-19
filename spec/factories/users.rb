FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Test@1234" }
    name { "Test User" }
    google_uid { nil }

    trait :with_google do
      google_uid { "google_#{rand(100000)}" }
      password { nil }
    end
  end
end
