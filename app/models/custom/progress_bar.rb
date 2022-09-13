require_dependency Rails.root.join("app", "models", "progress_bar").to_s

class ProgressBar < ApplicationRecord
  def projekt
    progressable.is_a?(Projekt) ? progressable : nil
  end
end
