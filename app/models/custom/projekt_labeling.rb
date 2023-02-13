class ProjektLabeling < ApplicationRecord
  belongs_to :projekt_label
  belongs_to :labelable, polymorphic: true
end
