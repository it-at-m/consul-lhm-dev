class ProjektPhase::QuestionPhase < ProjektPhase
  has_many :questions, -> { order(:id) }, foreign_key: :projekt_phase_id, class_name: "ProjektQuestion",
    inverse_of: :projekt_phase, dependent: :destroy

  def phase_activated?
    active?
  end

  def name
    "question_phase"
  end

  def resources_name
    "projekt_questions"
  end

  def default_order
    3
  end

  def resource_count
    questions.count
  end

  def question_list_enabled?
    settings.find_by(key: "feature.general.show_questions_list").value.present?
  end

  def admin_nav_bar_items
    %w[duration naming restrictions settings].push(resources_name)
  end

  def safe_to_destroy?
    questions.empty?
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
