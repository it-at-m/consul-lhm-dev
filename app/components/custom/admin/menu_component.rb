require_dependency Rails.root.join("app", "components", "admin", "menu_component").to_s

class Admin::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def booths?
      %w[officers booths shifts booth_assignments officer_assignments].include?(controller_name) && controller.class.parent == Admin::Poll ||
        controller_name == "polls" && action_name == "booth_assignments"
    end

    def officers_link
      [
        t("admin.menu.poll_officers"),
        admin_officers_path,
        %w[officers officer_assignments].include?(controller_name)
      ]
    end

    def deficiency_reports?
      ( %w[officers categories statuses settings].include?(controller_name) && controller.class.parent == Admin::DeficiencyReports )
    end

    def deficiency_reports_list
      [
        t("custom.admin.menu.deficiency_reports.list"),
        admin_deficiency_reports_path,
        controller_name == "deficiency_reports"
      ]
    end

    def deficiency_report_officers
      [
        t("custom.admin.menu.deficiency_reports.officers"),
        admin_deficiency_report_officers_path,
        controller_name == "officers" && controller.class.parent == Admin::DeficiencyReports
      ]
    end

    def deficiency_report_categories
      [
        t("custom.admin.menu.deficiency_reports.categories"),
        admin_deficiency_report_categories_path,
        controller_name == "categories" && controller.class.parent == Admin::DeficiencyReports
      ]
    end

    def deficiency_report_statuses
      [
        t("custom.admin.menu.deficiency_reports.statuses"),
        admin_deficiency_report_statuses_path,
        controller_name == "statuses" && controller.class.parent == Admin::DeficiencyReports
      ]
    end

    def deficiency_report_settings
      [
        t("custom.admin.menu.deficiency_reports.settings"),
        admin_deficiency_report_settings_path,
        controller_name == "settings" && controller.class.parent == Admin::DeficiencyReports
      ]
    end

    def settings?
      controllers_names = ["settings", "tags", "geozones", "images", "content_blocks",
                           "local_census_records", "imports"]
      controllers_names.include?(controller_name) &&
        controller.class.parent != Admin::Poll::Questions::Answers &&
        controller.class != Admin::DeficiencyReports::SettingsController
    end

    def settings_link
      [
        t("admin.menu.settings"),
        admin_settings_path,
        controller_name == "settings" &&
          controller.class != Admin::DeficiencyReports::SettingsController
      ]
    end
end
