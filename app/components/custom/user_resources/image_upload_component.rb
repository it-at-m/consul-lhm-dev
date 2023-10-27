class UserResources::ImageUploadComponent < ApplicationComponent
  def initialize(f, imageable:)
    @f = f
    @imageable = imageable
  end

  private

    def i18n_scope
      case @imageable
      when Debate
        "debates"
      when Proposal
        "proposals"
      else
        "other"
      end
    end
end
