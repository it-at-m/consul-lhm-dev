FactoryBot.define do
  factory :age_restriction do
    order { 1 }
    name { "MyString" }
    min_age { 1 }
    max_age { 1 }
  end
end
