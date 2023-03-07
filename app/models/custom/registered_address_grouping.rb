class RegisteredAddressGrouping < ApplicationRecord
  def restriction_options
    query = <<-SQL
      SELECT DISTINCT (groupings ->> '#{key}')
      FROM registered_addresses
    SQL

    ActiveRecord::Base.connection.execute(Arel.sql(query)).values.flatten.compact
  end
end
