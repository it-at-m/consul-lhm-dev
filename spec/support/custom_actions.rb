Dir["./spec/support/custom_actions/*.rb"].each { |f| require f }

module CustomActions
  include SharedActions
end
