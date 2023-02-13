FactoryBot.define do
  factory :projekt_label do
    name { Faker::Name.first_name }
    color { Faker::Color.hex_color }
    icon { %w[award bacon biking handshake heart home hourglass industry infinity info key kiss].sample }
    projekt { create(:projekt) }
  end
end
