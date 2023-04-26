// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require jquery_ujs
//= require jquery-ui/widgets/datepicker
//= require jquery-ui/i18n/datepicker-ar
//= require jquery-ui/i18n/datepicker-bs
//= require jquery-ui/i18n/datepicker-cs
//= require jquery-ui/i18n/datepicker-da
//= require jquery-ui/i18n/datepicker-de
//= require jquery-ui/i18n/datepicker-el
//= require jquery-ui/i18n/datepicker-es
//= require jquery-ui/i18n/datepicker-fa
//= require jquery-ui/i18n/datepicker-fr
//= require jquery-ui/i18n/datepicker-gl
//= require jquery-ui/i18n/datepicker-he
//= require jquery-ui/i18n/datepicker-hr
//= require jquery-ui/i18n/datepicker-id
//= require jquery-ui/i18n/datepicker-it
//= require jquery-ui/i18n/datepicker-nl
//= require jquery-ui/i18n/datepicker-pl
//= require jquery-ui/i18n/datepicker-pt-BR
//= require jquery-ui/i18n/datepicker-ru
//= require jquery-ui/i18n/datepicker-sl
//= require jquery-ui/i18n/datepicker-sq
//= require jquery-ui/i18n/datepicker-sv
//= require jquery-ui/i18n/datepicker-zh-CN
//= require jquery-ui/i18n/datepicker-zh-TW
//= require jquery-ui/i18n/datepicker-en-GB
//= require jquery-ui/widgets/autocomplete
//= require jquery-ui/widgets/sortable
//= require jquery-fileupload/basic
//= require foundation
//= require turbolinks
//= require turbolinks_anchors
//= require ckeditor/loader
//= require ckeditor/config.js
//= require_directory ./ckeditor
//= require social-share-button
//= require initial
//= require ahoy
//= require app
//= require check_all_none
//= require comments
//= require foundation_extras
//= require ie_alert
//= require location_changer
//= require moderator_comment
//= require moderator_debates
//= require moderator_proposals
//= require moderator_budget_investments
//= require moderator_proposal_notifications
//= require moderator_legislation_proposals
//= require gettext
//= require annotator
//= require jquery.amsify.suggestags
//= require tags
//= require users
//= require participation_not_allowed
//= require advanced_search
//= require registration_form
//= require suggest
//= require forms
//= require valuation_budget_investment_form
//= require embed_video
//= require fixed_bar
//= require banners
//= require social_share
//= require checkbox_toggle
//= require markdown-it
//= require markdown_editor
//= require html_editor
//= require cocoon
//= require answers
//= require questions
//= require legislation_admin
//= require legislation
//= require legislation_allegations
//= require legislation_annotatable
//= require legislation_draft_versions
//= require followable
//= require flaggable
//= require documentable
//= require imageable
//= require tree_navigator
//= require tag_autocomplete
//= require polls_admin
//= require leaflet
//= require map
//= require polls
//= require sortable
//= require table_sortable
//= require investment_report_alert
//= require send_newsletter_alert
//= require managers
//= require i18n
//= require globalize
//= require send_admin_notification_alert
//= require settings
//= require cookies
//= require columns_selector
//= require budget_edit_associations
//= require budget_hide_money
//= require datepicker
//= require leaflet.markercluster
//= require leaflet.locatecontrol
//= require_tree ./admin
//= require_tree ./sdg
//= require_tree ./sdg_management
//= require custom
//= require_tree ./custom

var initialize_modules = function() {
  "use strict";

  App.Answers.initialize();
  App.Questions.initialize();
  App.Comments.initialize();
  App.Users.initialize();
  App.Projekts.initialize();
  App.ResponsiveMenu.initialize();
  App.ParticipationNotAllowed.initialize();
  App.Tags.initialize();
  App.FoundationExtras.initialize();
  App.LocationChanger.initialize();
  App.CheckAllNone.initialize();
  App.IeAlert.initialize();
  App.AdvancedSearch.initialize();
  App.RegistrationForm.initialize();
  App.Suggest.initialize();
  App.Forms.initialize();
  App.ValuationBudgetInvestmentForm.initialize();
  App.EmbedVideo.initialize();
  App.FixedBar.initialize();
  App.Banners.initialize();
  App.SocialShare.initialize();
  App.CheckboxToggle.initialize();
  App.MarkdownEditor.initialize();
  App.HTMLEditor.initialize();
  App.LegislationAdmin.initialize();
  App.Legislation.initialize();
  if ($(".legislation-annotatable").length) {
    App.LegislationAnnotatable.initialize();
  }
  App.TreeNavigator.initialize();
  App.Documentable.initialize();
  App.Imageable.initialize();
  App.TagAutocomplete.initialize();
  App.PollsAdmin.initialize();
  App.Map.initialize();
  App.Polls.initialize();
  App.Sortable.initialize();
  App.TableSortable.initialize();
  App.InvestmentReportAlert.initialize();
  App.SendNewsletterAlert.initialize();
  App.Managers.initialize();
  App.Globalize.initialize();
  App.SendAdminNotificationAlert.initialize();
  App.Settings.initialize();
  if ($("#js-columns-selector").length) {
    App.ColumnsSelector.initialize();
  }
  App.AdminBudgetsWizardCreationStep.initialize();
  App.AdminMachineLearningScripts.initialize();
  App.BudgetEditAssociations.initialize();
  App.BudgetHideMoney.initialize();
  App.Datepicker.initialize();
  App.ClickOutWarning.initialize();
  App.IframeFilter.initialize();
  App.SDGRelatedListSelector.initialize();
  App.SDGManagementRelationSearch.initialize();
  App.SDGCustom.initialize();
  App.Geozones.initialize();
  App.ExpandProposalsMap.initialize();
  App.MapRefresh.initialize();
  App.PollsCustom.initialize();
  App.RadioButtonFilter.initialize();
  App.DeficiencyReports.initialize();
  App.AccessibilityFixes.initialize();
  App.CustomPages.initialize();
  App.CustomAdmin.initialize();
  App.ModerationCustom.initialize();
  App.CopyContent.initialize();
  App.FooterPhasesComponentCustom.initialize();
  App.RemoteLinksPushState.initialize();
  App.ProjektQuestionCustom.initialize();
  App.LivesubmitCheckboxCustom.initialize();
  App.OrbitInPopupFixCustom.initialize();
  App.ModalNotification.initialize();
  App.VerificationForm.initialize();

  if ($("#projekt-selector-fields").length) {
    App.ProjektSelector.initialize();
  }
};

var destroy_non_idempotent_modules = function() {
  "use strict";

  App.ColumnsSelector.destroy();
  App.Datepicker.destroy();
  App.HTMLEditor.destroy();
  App.LegislationAnnotatable.destroy();
  App.Map.destroy();
  App.SocialShare.destroy();
};

$(document).on("turbolinks:load", initialize_modules);
$(document).on("turbolinks:before-cache", destroy_non_idempotent_modules);

ahoy.configure({cookies: false});
