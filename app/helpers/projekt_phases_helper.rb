module ProjektPhasesHelper
  def projekt_phase_navbar_link(action)
    class_name = ["static-subnav-link", static_subnav_link_current?(action)].reject(&:blank?).join(" ")

    link_to namespace_projekt_phase_path(action: action), class: class_name do
      t("custom.admin.projekt_phases.nav_bar.#{action}")
    end
  end
end
