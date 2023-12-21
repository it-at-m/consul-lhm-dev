class ProjektManagement::Poll::BaseController < ProjektManagement::BaseController
  include FeatureFlags

  feature_flag :polls
end
