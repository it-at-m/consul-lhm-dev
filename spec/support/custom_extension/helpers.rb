module CustomExtension
  module Helpers
    def create_projekt_tree
      parent_projekt = create(:projekt)
      create(:projekt, parent: parent_projekt)
      create(:projekt, parent: parent_projekt)
    end
  end
end
