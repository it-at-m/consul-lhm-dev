class ProjektManagement::Legislation::BaseController < ProjektManagement::BaseController
  include FeatureFlags

  feature_flag :legislation
end
