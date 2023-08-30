FactoryBot.define do
  factory :email_activity do
    email { "MyString" }
    action { "MyString" }
    actionable { nil }
  end
end
