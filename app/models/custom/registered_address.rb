class RegisteredAddress < ApplicationRecord
  validates :registered_address_city_id, :registered_address_street_id, :street_number, presence: true

  belongs_to :registered_address_city, class_name: "RegisteredAddress::City"
  belongs_to :registered_address_street, class_name: "RegisteredAddress::Street"
  has_many :users, dependent: :nullify

  def self.import(file_path)
    fixed_attribute_keys = %w[street_number street_number_extension]
    restricted_key_names = %w[city street_name plz] + fixed_attribute_keys

    grouping_keys = CSV.read(file_path, headers: true).headers
      .map(&:strip)
      .reject { |header| header.in? restricted_key_names }

    create_groupings_from_csv(grouping_keys)

    CSV.foreach(file_path, headers: true) do |row|
      fixed_attributes_hash = row.to_hash.slice(*fixed_attribute_keys)

      street_id = find_or_create_registered_address_street(row["street_name"], row["plz"]).id
      fixed_attributes_hash[:registered_address_street_id] = street_id

      city_id = find_or_create_registered_address_city(row["city"]).id
      fixed_attributes_hash[:registered_address_city_id] = city_id

      grouping_attributes_hash = row.to_hash.slice(*grouping_keys)

      RegisteredAddress.find_or_create_by!(fixed_attributes_hash).update!(groupings: grouping_attributes_hash)
    rescue ActiveRecord::RecordInvalid
      next
    end
  end

  def self.find_or_create_registered_address_street(street_name, plz)
    RegisteredAddress::Street.find_or_create_by!(name: street_name, plz: plz)
  end

  def self.find_or_create_registered_address_city(city_name)
    RegisteredAddress::City.find_or_create_by!(name: city_name)
  end

  def self.create_groupings_from_csv(grouping_keys)
    grouping_keys.each do |grouping_key|
      RegisteredAddress::Grouping.find_or_create_by!(key: grouping_key)
    end
  end

  def formatted_name
    "#{registered_address_street.name} #{street_number}#{street_number_extension}"
  end
end
