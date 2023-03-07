FactoryBot.define do
  factory :registered_address do
    city { "City" }
    sequence(:street_number, &:to_s)
    street_number_extension { "a" }
    groupings do
      {
        "bezirk" => "1",
        "stadtteil" => "11",
        "schulbezirk" => "2"
      }
    end
    association :registered_address_street
  end

  factory :registered_address_street do
    name { "Street name" }
    plz { "12345" }
  end

  factory :registered_adress_grouping do
    key { "bezirk" }
    name { "Bezirk" }
  end
end
