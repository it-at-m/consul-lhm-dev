FactoryBot.define do
  factory :projekt do
    sequence(:name) { |n| "Projekt_#{SecureRandom.hex}" }

    total_duration_start { 1.month.ago }
    total_duration_end { 1.month.from_now }

    color { "#00AA02" }
    icon { "biking" }
  end
end
