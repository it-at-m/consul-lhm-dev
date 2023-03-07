class RegisteredAddress < ApplicationRecord
  validates :city, :registered_address_street_id, :street_number, presence: true

  belongs_to :registered_address_street
  has_many :users, dependent: :nullify

  def self.import(file_path)
    fixed_attribute_keys = %w[city street_number street_number_extension]

    grouping_keys = CSV.read(file_path, headers: true).headers
      .map(&:strip)
      .reject { |header| header.in?(fixed_attribute_keys + ["street_name", "plz"]) }

    create_groupings_from_csv(grouping_keys)

    CSV.foreach(file_path, headers: true) do |row|
      fixed_attributes_hash = row.to_hash.slice(*fixed_attribute_keys)
      street_id = create_registered_address_street(row["street_name"], row["plz"]).id
      fixed_attributes_hash[:registered_address_street_id] = street_id
      grouping_attributes_hash = row.to_hash.slice(*grouping_keys)

      RegisteredAddress.find_or_create_by!(fixed_attributes_hash).update!(groupings: grouping_attributes_hash)
    rescue ActiveRecord::RecordInvalid
      next
    end
  end

  def self.create_registered_address_street(street_name, plz)
    RegisteredAddressStreet.find_or_create_by!(name: street_name, plz: plz)
  end

  def self.create_groupings_from_csv(grouping_keys)
    grouping_keys.each do |grouping_key|
      RegisteredAddressGrouping.find_or_create_by!(key: grouping_key)
    end
  end
end
