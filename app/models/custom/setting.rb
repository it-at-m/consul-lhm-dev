require_dependency Rails.root.join("app", "models", "setting").to_s

class Setting < ApplicationRecord
  attr_accessor :form_field_disabled, :dependent_setting_ids, :dependent_setting_action

  def type
    if %w[feature process proposals map html homepage uploads projekts sdg].include? prefix
      prefix
    elsif %w[remote_census].include? prefix
      key.rpartition(".").first
    elsif %w[deficiency_reports].include? prefix
      key.rpartition(".").first
    elsif %w[extended_feature].include? prefix
      key.rpartition(".").first
    elsif %w[extended_option].include? prefix
      key.rpartition(".").first
    elsif %w[extra_fields].include? prefix
      key.rpartition(".").first
    else
      "configuration"
    end
  end

  class << self

    def defaults
      {
        "feature.featured_proposals": nil,
        "feature.facebook_login": false,
        "feature.google_login": false,
        "feature.twitter_login": false,
        "feature.wordpress_login": false,
        "feature.public_stats": true,
        "feature.signature_sheets": true,
        "feature.user.recommendations": false,
        # "feature.user.recommendations_on_debates": true,
        # "feature.user.recommendations_on_proposals": true,
        "feature.user.skip_verification": "true",
        "feature.community": true,
        "feature.map": true,
        "feature.allow_attached_documents": true,
        "feature.allow_images": true,
        "feature.help_page": true,
        "feature.remote_translations": nil,
        "feature.translation_interface": nil,
        "feature.remote_census": nil,
        "feature.valuation_comment_notification": true,
        "feature.graphql_api": true,
        "feature.sdg": false,
        "feature.machine_learning": false,
        # "feature.remove_investments_supports": false,
        "homepage.widgets.feeds.active_projekts": true,
        "homepage.widgets.feeds.polls": true,
        "homepage.widgets.feeds.debates": true,
        "homepage.widgets.feeds.processes": false,
        "homepage.widgets.feeds.proposals": true,
        "homepage.widgets.feeds.expired_projekts": true,
        "homepage.widgets.feeds.investment_proposals": true,
        # Code to be included at the top (inside <body>) of every page
        "html.per_page_code_body": "",
        # Code to be included at the top (inside <head>) of every page (useful for tracking)
        "html.per_page_code_head": "",
        "map.latitude": 48.1372,
        "map.longitude": 11.5754,
        "map.zoom": 10,
        "process.debates": true,
        "process.proposals": true,
        "process.polls": true,
        "process.budgets": true,
        "process.legislation": true,
        "process.projekts": true,
        "proposals.successful_proposal_id": nil,
        "proposals.poll_short_title": nil,
        "proposals.poll_description": nil,
        "proposals.poll_link": nil,
        "proposals.email_short_title": nil,
        "proposals.email_description": nil,
        "proposals.poster_short_title": nil,
        "proposals.poster_description": nil,
        # Images and Documents
        "uploads.images.title.min_length": 4,
        "uploads.images.title.max_length": 80,
        "uploads.images.min_width": 0,
        "uploads.images.min_height": 475,
        "uploads.images.max_size": 5,
        "uploads.images.content_types": "image/jpeg image/png",
        "uploads.documents.max_amount": 3,
        "uploads.documents.max_size": 3,
        "uploads.documents.content_types": "application/pdf",
        # Names for the moderation console, as a hint for moderators
        # to know better how to assign users with official positions
        "official_level_1_name": I18n.t("seeds.settings.official_level_1_name"),
        "official_level_2_name": I18n.t("seeds.settings.official_level_2_name"),
        "official_level_3_name": I18n.t("seeds.settings.official_level_3_name"),
        "official_level_4_name": I18n.t("seeds.settings.official_level_4_name"),
        "official_level_5_name": I18n.t("seeds.settings.official_level_5_name"),
        "max_ratio_anon_votes_on_debates": 50,
        "max_votes_for_debate_edit": 1000,
        "max_votes_for_proposal_edit": 1000,
        "comments_body_max_length": 1000,
        "proposal_code_prefix": "CONSUL",
        "votes_for_proposal_success": 10000,
        "months_to_archive_proposals": 12,
        # Users with this email domain will automatically be marked as level 1 officials
        # Emails under the domain's subdomains will also be included
        "email_domain_for_officials": "",
        "facebook_handle": nil,
        "instagram_handle": nil,
        "telegram_handle": nil,
        "twitter_handle": nil,
        "twitter_hashtag": nil,
        "youtube_handle": nil,
        "url": "http://example.com", # Public-facing URL of the app.
        # CONSUL installation's organization name
        "org_name": "CONSUL",
        "meta_title": nil,
        "meta_description": nil,
        "meta_keywords": nil,
        "proposal_notification_minimum_interval_in_days": 3,
        "direct_message_max_per_day": 3,
        "mailer_from_name": "CONSUL",
        "mailer_from_address": "noreply@consul.dev",
        "min_age_to_participate": 16,
        "hot_score_period_in_days": 31,
        "related_content_score_threshold": -0.3,
        "featured_proposals_number": 3,
        "feature.dashboard.notification_emails": nil,
        "machine_learning.comments_summary": false,
        "machine_learning.related_content": false,
        "machine_learning.tags": false,
        "postal_codes": "",
        "remote_census.general.endpoint": "",
        "remote_census.request.method_name": "",
        "remote_census.request.structure": "",
        "remote_census.request.document_type": "",
        "remote_census.request.document_number": "",
        "remote_census.request.date_of_birth": "",
        "remote_census.request.postal_code": "",
        "remote_census.response.date_of_birth": "",
        "remote_census.response.postal_code": "",
        "remote_census.response.district": "",
        "remote_census.response.gender": "",
        "remote_census.response.name": "",
        "remote_census.response.surname": "",
        "remote_census.response.valid": "",
        "sdg.process.debates": false,
        "sdg.process.proposals": false,
        "sdg.process.polls": false,
        "sdg.process.budgets": false,
        "sdg.process.legislation": false,
        "sdg.process.projekts": true,

        "projekts.show_archived.sidebar": true,
        "projekts.second_level_projekts_in_active_filter": false,
        "projekts.second_level_projekts_in_archived_filter": false,
        "projekts.set_default_sorting_to_newest": false,

        "deficiency_reports.show_in_main_menu": false,
        "deficiency_reports.admins_must_assign_officer": false,
        "deficiency_reports.admins_must_approve_officer_answer": false,
        "deficiency_reports.allow_voting": false,
        "deficiency_reports.enable_comments": true,
        "deficiency_reports.intro_text": false,
        "deficiency_reports.enable_geoman_controls_in_maps": true,

        # "extended_feature.general.elasticsearch": false,

        "extended_feature.general.extended_editor_for_admins": true,
        "extended_feature.general.extended_editor_for_users": true,
        "extended_feature.general.language_switcher_in_menu": false,
        "extended_feature.general.links_to_create_resources_in_menu": false,
        "extended_feature.general.enable_projekt_events_page": false,
        "extended_feature.general.enable_google_translate": false,
        "extended_option.general.title": 'Öffentlichkeitsbeteiligung',
        "extended_option.general.subtitle": 'in der Stadt CONSUL',
        "extended_option.general.launch_date": '',

        "extended_feature.gdpr.gdpr_conformity": false,
        "extended_feature.gdpr.link_out_warning": true,
        "extended_feature.gdpr.two_click_iframe_solution": true,
        "extended_option.gdpr.devise_timeout_min": 30,
        "extended_option.gdpr.devise_verification_token_validity_days": 3,

        "extended_feature.modulewide.enable_categories": false,
        # temporarily disabled  "extended_feature.modulewide.enable_custom_tags": false,
        "extended_feature.modulewide.show_number_of_entries_in_modules": true,
        "extended_feature.modulewide.show_affiliation_filter_in_index_sidebar": false,
        "extended_feature.modulewide.hide_comment_replies_by_default": false,
        "extended_feature.modulewide.custom_help_text_in_modules": false,

        "extended_feature.debates.intro_text_for_debates": true,
        "extended_feature.debates.head_image_for_debates": true,
        "extended_feature.debates.enable_projekt_filter": true,
        "extended_feature.debates.enable_my_posts_filter": true,
        "selectable_setting.debates.default_order": "created_at",

        "extended_feature.proposals.intro_text_for_proposals": true,
        "extended_feature.proposals.enable_proposal_support_withdrawal": true,
        "extended_feature.proposals.show_selected_proposals_in_proposal_sidebar": false,
        "extended_feature.proposals.show_suggested_proposals_in_proposal_sidebar": false,
        "extended_feature.proposals.enable_projekt_filter": true,
        "extended_feature.proposals.enable_my_posts_filter": true,
        "extended_option.proposals.max_active_proposals_per_user": 100,
        "extended_option.proposals.description_max_length": 6000,
        "selectable_setting.proposals.default_order": "created_at",

        "extended_feature.polls.intro_text_for_polls": true,
        "extended_feature.polls.enable_projekt_filter": true,

        "extended_feature.deficiency_reports.enable_my_posts_filter": true,

        "extended_feature.projekts_overview_page_navigation.show_in_navigation": true,
        "extended_feature.projekts_overview_page_navigation.show_index_order_all": true,
        "extended_feature.projekts_overview_page_navigation.show_index_order_underway": true,
        "extended_feature.projekts_overview_page_navigation.show_index_order_ongoing": true,
        "extended_feature.projekts_overview_page_navigation.show_index_order_upcoming": true,
        "extended_feature.projekts_overview_page_navigation.show_index_order_expired": true,
        "extended_feature.projekts_overview_page_navigation.show_index_order_individual_list": true,

        "extended_feature.projekts_overview_page_footer.show_in_index_order_all": true,
        "extended_feature.projekts_overview_page_footer.show_in_index_order_underway": true,
        "extended_feature.projekts_overview_page_footer.show_in_index_order_ongoing": true,
        "extended_feature.projekts_overview_page_footer.show_in_index_order_upcoming": true,
        "extended_feature.projekts_overview_page_footer.show_in_index_order_expired": true,
        "extended_feature.projekts_overview_page_footer.show_in_index_order_individual_list": true,

        "extra_fields.registration.extended": false,
        "extra_fields.registration.check_documents": false,
        "extra_fields.verification.check_documents": false,
      }
    end

    def reset_defaults
      defaults.each { |name, value| self[name] = value }
    end

    def destroy_obsolete
      Setting.all.each{ |setting| setting.destroy unless defaults.keys.include?(setting.key.to_sym) }
    end
  end
end
