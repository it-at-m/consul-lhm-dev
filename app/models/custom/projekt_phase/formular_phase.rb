class ProjektPhase::FormularPhase < ProjektPhase
  has_one :formular, foreign_key: :projekt_phase_id, dependent: :restrict_with_exception,
    inverse_of: :projekt_phase

  after_create :create_formular

  def phase_activated?
    active?
  end

  def name
    "formular_phase"
  end

  def resources_name
    "formular"
  end

  def default_order
    12
  end

  def admin_nav_bar_items
    %w[duration naming settings formular formular_answers]
  end

  def safe_to_destroy?
    formular.blank?
  end

  def create_formular
    Formular.create!(projekt_phase: self)
  end

  def subscribable?
    false
  end
end
