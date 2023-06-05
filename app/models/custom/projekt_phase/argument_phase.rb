class ProjektPhase::ArgumentPhase < ProjektPhase
  has_many :projekt_arguments, foreign_key: :projekt_phase_id,
    dependent: :restrict_with_exception, inverse_of: :projekt_phase

  def phase_activated?
    # projekt.questions.any?
    active?
  end

  def name
    "argument_phase"
  end

  def resources_name
    "projekt_arguments"
  end

  def default_order
    4
  end

  def resource_count
    projekt_arguments.count
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
