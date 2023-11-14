(function() {
  "use strict";

  App.ProjektSelector = {
    initialized: false,

    toggleProjektGroup: function(selector) {
      if (selector.dataset.target) {
        var target_projekt_group_id = selector.dataset.target;
        $(target_projekt_group_id).toggle();
      }
    },

    selectProjekt: function($projekt) {
      var $selectedProjekt = $projekt.clone().removeClass("js-select-projekt");
      var projektId = $projekt.data("projektId");
      var $currentProjektSelector = $projekt.closest(".projekt-selector");
      var $nextProejektSelector = $currentProjektSelector.nextAll(".projekt-selector").first();
      var $nextSpacer = $currentProjektSelector.next();

      App.ProjektSelector.resetNextSelectors($currentProjektSelector);

      // replace placeholder with projekt
      $currentProjektSelector.find(".selected-projekt").first().hide();
      $currentProjektSelector.children(".projekt").remove();
      $currentProjektSelector.prepend($selectedProjekt);

      // show next selector
      if ($selectedProjekt.data("projektSelectableChildren")) {
        // $nextSpacer.css('visibility', '-visible')
        $nextSpacer.addClass("-visible");
        // $nextProejektSelector.css('visibility', '-visible')
        $nextProejektSelector.addClass("-visible");
        $nextProejektSelector.attr("data-target", "#group-for-" + projektId);
        $nextProejektSelector.children(".projekt_group").hide();
      }

      // conditionally toggle next group to select
      if (!$selectedProjekt.data("projektSelectable")) {
        $("#group-for-" + projektId).show();
      }

      // update selected projekt
      if ($selectedProjekt.data("projektSelectable")) {
        App.ProjektSelector.resetSelectedProjectStyles();

        // $('[id$="projekt_id"]').val(projektId)
        $selectedProjekt.css('background-color', '#004A83')
        $selectedProjekt.css('color', '#FFF')
        $selectedProjekt.find('.projekt-icon .fas').css('color', '#FFF')
        $selectedProjekt.closest('.projekt-selector').css('color', '#FFF')
        App.ProjektSelector.addNextProjektPlaceholder($nextProejektSelector, "(optional)")
      } else {
        App.ProjektSelector.resetSelectedProjectStyles();
        $('[id$="projekt_id"]').val('')
        $selectedProjekt.css('background-color', '#CEE9F9')
        App.ProjektSelector.addNextProjektPlaceholder($nextProejektSelector, "(verpflichtend)")
      }

      App.ProjektSelector.updatePhasesSelector(projektId);

      // reset form when projekt changes TODO
      $('[id$="projekt_phase_id"]').val("");

      $("#map-container").hide();

      var $firstProjektPhase = $("#projekt-phase-group-for-projekt-" + projektId + " .js-select-projekt-phase:first");
      App.ProjektSelector.selectProjektPhase($firstProjektPhase);

      // this.clearBannerColor();
    },

    selectProjektPhase: function($projektPhase) {
      var projektPhaseId = $projektPhase.data("projektPhaseId");
      $("[id$=\"projekt_phase_id\"]").val(projektPhaseId);

      if ($("span#persisted-resource-data").length) {
        var persistedResourceData = $("span#persisted-resource-data").data();

        if (persistedResourceData.resourceMap) {
          $("#map-container").show();
        }
      } else {
        this.replaceProjektMapOnResourceCreation($projektPhase);
      }

      this.updateFormHeading(projektPhaseId);
      this.updateProjektSelectorHint(projektPhaseId);
      this.updateActivePhaseSelector(projektPhaseId);
      this.toggleImageAttachment($projektPhase);
      this.toggleDocumentAttachment($projektPhase);
      this.toggleSummary($projektPhase);
      this.toggleExternalVideoUrl($projektPhase);
      this.toggleOnBehalfOf($projektPhase);
      this.toggleExternalFieldsHeader($projektPhase);
      this.toggleTagging($projektPhase);
      this.changeResourceFormTitle($projektPhase);
    },

    updateProjektSelectorHint: function(projektPhaseId) {
      var $hintElement = $('[id$="_creation_recommendations"]').first();
      if (!$hintElement.length) {
        return;
      }

      $.ajax("/projekt_phases/" + projektPhaseId + "/selector_hint_html", {
        type: "GET",
        dataType: "html",
        success: function(data) {
          $hintElement.html(data);
          $(document).foundation();
        }
      });
    },

    updateFormHeading: function(projektPhaseId) {
      if ($(".admin-content").length) {
        return;
      }

      var $header = $("header h1").first();

      $.ajax("/projekt_phases/" + projektPhaseId + "/form_heading_text", {
        type: "GET",
        dataType: "html",
        success: function(data) {
          $header.text(data);
          $(document).foundation();
        }
      });
    },

    updateActivePhaseSelector: function(projektPhaseId) {
      $(".projekt-phase-selector").removeClass("active");
      $("#projekt-phase-selector-" + projektPhaseId).addClass("active");
    },

    replaceProjektMapOnResourceCreation: function($projektPhase) {
      App.Map.destroy();

      if ($projektPhase.data("showMap")) {
        $("#map-container").show();

        $.ajax("/projekt_phases/" + $projektPhase.data("projektPhaseId") + "/map_html", {
          type: "GET",
          dataType: "html",
          success: function(data) {
            if ($projektPhase.data("vcMap")) {
              $("div.map_location.map").first().replaceWith(data);
              App.VCMap.initialize();
            } else {
              App.Map.destroy();
              $("div.map_location.map").first().replaceWith(data);
              App.Map.initialize();
              App.Map.maps[0].setView([$projektPhase.data("latitude"), $projektPhase.data("longitude")], $projektPhase.data("zoom")).invalidateSize();
            }
          }
        });
      } else {
        $("#map-container").hide();
      }
    },

    toggleImageAttachment: function($projektPhase) {
      var $userResourcesForm = $(".js-user-resources-form");

      if (!!$projektPhase.data("allowAttachedImage")) {
        $("#attach-image").show();
        $userResourcesForm.removeClass("-no-image");
      } else {
        $("#attach-image #nested-image .direct-upload").remove();
        $("#new_image_link").removeClass("hide");
        $("#attach-image").hide();
        $userResourcesForm.addClass("-no-image");
      }
    },

    toggleDocumentAttachment: function($projektPhase) {
      var showDocuments = !!$projektPhase.data("allowAttachedDocument");

      $("#attach-documents").toggle(showDocuments);
      $(".js-sidebar-documment-attacher-section").toggle(showDocuments);
    },

    toggleSummary: function($projektPhase) {
      $(".summary-field").toggle($projektPhase.data("showSummary"));
    },

    toggleExternalVideoUrl: function($projektPhase) {
      var allowVideo = !!$projektPhase.data("allowVideo");

      $("#external-video-url-fields").toggle(allowVideo);
      $(".js-sidebar-external-video-section").toggle(allowVideo);
    },

    toggleOnBehalfOf: function($projektPhase) {
      $("#create-on-behalf-of").toggleClass("hide", !$projektPhase.data("createOnBehalfOf"));
    },

    toggleExternalFieldsHeader: function($projektPhase) {
      var $behalfOfFields = $(".js-sidebar-behalf-of");

      if (
        $("#create-on-behalf-of").is(":hidden") &&
        $("#attach-documents").is(":hidden") &&
        (!$("#external-video-url-fields").length || $("#external-video-url-fields").is(":hidden"))
      ) {
        $("#additional-fields-title").hide();
        $behalfOfFields.hide();
      } else {
        $("#additional-fields-title").show();
        $behalfOfFields.show();
      }
    },

    toggleTagging: function($projektPhase) {
      var showTagging = !!$projektPhase.data("projekt-label-ids") || !!$projektPhase.data("sentiment-ids");
      $("legend.tagging").toggleClass('hide', !showTagging);

      this.updateProjektLabelSelector($projektPhase);
      this.updateSentimentSelector($projektPhase);
    },

    updateProjektLabelSelector: function($projektPhase) {
      if ($projektPhase.data("projekt-labels-name")) {
        $("#projekt_labels_selector label[for$=_projekt_labels]").text($projektPhase.data("projekt-labels-name").replaceAll("_", " "));
        $(".js-sidebar-label-section .sidebar-card--header-text").text($projektPhase.data("projekt-labels-name").replaceAll("_", " "));
        $(".js-projekt-labels-selector .sidebar-card--title-text").text($projektPhase.data("projekt-labels-name").replaceAll("_", " "));
      } else {
        $("#projekt_labels_selector label[for$=_projekt_labels]").text("Labels");
        $(".js-sidebar-label-section .sidebar-card--header-text").text("Labels");
        $(".js-projekt-labels-selector .sidebar-card--title-text").text("Labels");
      }

      var labelIdsToShow = [];

      if ($projektPhase.data("projekt-label-ids")) {
        labelIdsToShow = $projektPhase.data("projekt-label-ids").toString().split(",");
      }

      var hideTaggings = labelIdsToShow.join().length === 0;

      $(".js-sidebar-label-section, #projekt_labels_selector").toggleClass("hide", hideTaggings);
      $("#projekt_labels_selector input[type=checkbox]").prop("checked", false);

      $("#projekt_labels_selector .projekt-label").each(function(_index, label) {
        var dontHaveLabel = !labelIdsToShow.includes($(label).data("labelId").toString());

        $(label).toggleClass("hide", dontHaveLabel);
      });
    },

    updateSentimentSelector: function($projektPhase) {
      if ($projektPhase.data("sentiments-name")) {
        var sentimentName = $projektPhase.data("sentiments-name").replaceAll("_", " ");
        $("#sentiment_selector label[for$=_sentiment_id]").text(sentimentName);
        $(".js-sidebar-sentiment-section .sidebar-card--header-text").text(sentimentName);
        $(".js-sentiments-selector .sidebar-card--title-text").text(sentimentName);
      } else {
        var sentimentName = "Sentiments";
        $("#sentiment_selector label[for$=_sentiment_id]").text(sentimentName);
        $(".js-sidebar-sentiment-section .sidebar-card--header-text").text(sentimentName);
        $(".js-sentiments-selector .sidebar-card--title-text").text(sentimentName);
      }

      var sentimentIdsToShow = [];

      if ($projektPhase.data("sentiment-ids")) {
        sentimentIdsToShow = $projektPhase.data("sentiment-ids").toString().split(",");
      }

      var hideSentimentsSection = sentimentIdsToShow.join().length === 0;

      $(".js-sidebar-sentiment-section, #sentiment_selector").toggleClass("hide", hideSentimentsSection);
      $("#sentiment_selector input[type=radio]").prop("checked", false);

      $("#sentiment_selector .sentiment").each(function(_index, sentiment) {
        var dontHaveSentiment = !sentimentIdsToShow.includes($(sentiment).data("sentimentId").toString());
        $(sentiment).toggleClass("hide", dontHaveSentiment);
      });
    },

    changeResourceFormTitle: function($projektPhase) {
      // if (!this.initialized) {
      //   return;
      // }

      var phaseFormTitle = $projektPhase.data("resourceFormTitle");

      if (phaseFormTitle && phaseFormTitle.length > 0) {
        $(".user-resources-form--title").text(phaseFormTitle);
      } else {
        $(".user-resources-form--title").text(this.defaultFormTitle);
      }
    },

    storeDefaultFormTitle: function() {
      this.defaultFormTitle = $(".user-resources-form--title").text();
    },

    addNextProjektPlaceholder: function($nextProejektSelector, text) {
      var indexOfProjektSelector = $(".projekt-selector").index($nextProejektSelector);

      var projektSelectorPlaceholder;

      if (indexOfProjektSelector === 1) {
        projektSelectorPlaceholder = "Wähle Kategorie " + text;
      } else if (indexOfProjektSelector === 2) {
        projektSelectorPlaceholder = "Wähle Unterkategorie " + text;
      }

      $nextProejektSelector.find(".selected-projekt-placeholder").html(projektSelectorPlaceholder);
    },

    resetSelectedProjectStyles: function() {
      $(".projekt-selector > .projekt")
        .css("background-color", "#CEE9F9")
        .css("color", "#0a0a0a");

      $(".projekt-selector").css("color", "#0a0a0a");

      $(".projekt-selector").find(".projekt .projekt-icon .fas").css("color", "#222");
    },

    resetNextSelectors: function($selector) {
      $selector.nextAll().each(function() {
        this.classList.remove("-visible");

        var $nextSelector = $(this);
        $nextSelector.find(".selected-projekt").show();
        $nextSelector.children(".projekt").remove();
      });
    },

    updatePhasesSelector: function(projektId) {
      $("#projekt-phase-selector-fields").find(".projekt-phase-group").hide();
      $("#projekt-phase-group-for-projekt-" + projektId).show();
    },

    preselectProjektPhase: function() {
      // get preselcted projekt id
      var selectedProjektId;
      var selectedProjektPhaseId;
      var url = new URL(window.location.href);

      if (url.searchParams.get("projekt_phase_id")) {
        selectedProjektId = url.searchParams.get("projekt_id");
        selectedProjektPhaseId = url.searchParams.get("projekt_phase_id");
      } else {
        selectedProjektId = $("[id$='projekt_id']").val();
        selectedProjektPhaseId = $("[id$='projekt_phase_id']").val();
      }

      if ( selectedProjektId === "" || selectedProjektPhaseId === "" ) {
        return false;
      }

      // get ordered array of parent projekts
      var projektIdsToShow = [selectedProjektId];
      var $selectedProjekt = $("#projekt_" + selectedProjektId);

      while ($selectedProjekt.data("parentId")) {
        projektIdsToShow.unshift($selectedProjekt.data("parentId"));
        $selectedProjekt = $("#projekt_" + $selectedProjekt.data("parentId"));
      }

      // show projekts staring with top parent and select projekt
      $.each(projektIdsToShow, function(_index, projektId) {
        var $selectedProjektToShow = $("#projekt_" + projektId);
        App.ProjektSelector.selectProjekt($selectedProjektToShow);
        $selectedProjektToShow.closest(".projekt_group").hide();
      });

      // if ( $selectedProjekt.data('hideProjektSelector') ) {
      //   $('#projekt-selector-block').prev('legend').hide();
      //   $('#projekt-selector-block').hide();
      // }

      // select projekt phase
      var $selectedProjektPhase = $("#projekt-phase-selector-" + selectedProjektPhaseId)
      App.ProjektSelector.selectProjektPhase($selectedProjektPhase);
    },

    // accessibility functions
    accessibilityProjektSelector: function(selector, event) {
      // if group hidden and enter or down arrow pressed - toggle(show) grooup
      if (!$(selector).children(".projekt_group.-visible").length && (event.which === 13 || event.which === 40)) {
        App.ProjektSelector.toggleProjektGroup(selector);
      }

      // if group -visible and down arrow pressed - jump to grooup
      if ($(selector).children(".projekt_group.-visible").length && event.which === 40) {
        $(selector).children(".projekt_group.-visible").first().find(".js-select-projekt").first().focus();
      }

      // if group -visible and enter or up arrow pressed - toggle(hide) group
      if ($(selector).children(".projekt_group.-visible").length && (event.which === 13 || event.which === 38)) {
        App.ProjektSelector.toggleProjektGroup(selector);
      }

      if (event.which === 37) { // left arrow click
        $(selector).prevAll(".projekt-selector").first().focus();
        $(selector).prevAll(".projekt-selector").first().click();
        $(selector).children(".projekt_group.-visible").hide();
      }

      if (event.which === 39) { // right arrow click
        $(selector).nextAll(".projekt-selector").first().focus();
        $(selector).nextAll(".projekt-selector").first().click();
        $(selector).children(".projekt_group.-visible").hide();
      }
    },

    accessibilityProjekt: function(projekt, event) {
      if (event.which === 13) { // enter pressed
        $(projekt).click();
        $(projekt).closest(".projekt-selector").nextAll(".projekt-selector").first().focus();
      }

      if (event.which === 40) { // down button pressed
        $(projekt).next().focus();
      }

      if (event.which === 38) { // up button pressed
        if ($(projekt).prev().length) {
          $(projekt).prev().focus();
        } else {
          $(projekt).closest(".projekt-selector").focus();
        }
      }
    },

    selectLabel: function($label) {
      var labelId = $label.data("labelId");
      var $labelCheckBox = $("#projekt-labels-checkboxes [id*='_projekt_label_ids_" + labelId + "']");
      $labelCheckBox.prop("checked", !$labelCheckBox.prop("checked"));

      if ($labelCheckBox.prop("checked")) {
        var labelBackgroundColor = $label.data("backgroundColor");
        var labelTextColor = $label.data("textColor");
        $label.css("background-color", labelBackgroundColor);
        $label.css("color", labelTextColor);
      } else {
        $label.css("background-color", "#767676");
        $label.css("color", "#fff");
      }
    },

    selectProjektSentiment: function($projektSentiment) {
      this.setBannerColor($projektSentiment.data('sentimentColor'));
    },

    setBannerColor: function(color) {
      $(".js-user-resources-form--banner-editor").css("background-color", color);
    },

    clearBannerColor: function() {
      $(".js-user-resources-form--banner-editor").css("background-color", "");
    },

    initialize: function() {
      $("body").on("click", ".js-toggle-projekt-group", function(event) {
        App.ProjektSelector.toggleProjektGroup(event.currentTarget);
      });

      $("body").on("click", ".js-select-projekt", function(event) {
        App.ProjektSelector.selectProjekt($(event.currentTarget), true);
      });

      $("body").on("click", ".js-select-projekt-phase", function(event) {
        App.ProjektSelector.selectProjektPhase($(event.currentTarget), true);
      });

      $(".js-new-resource").on("click", function(event) {
        if ($(event.target).closest(".js-toggle-projekt-group").length === 0) {
          $(".projekt-group").hide();
        }
      });

      $("body").on("click", ".js-select-projekt-label", function(event) {
        App.ProjektSelector.selectLabel($(event.currentTarget));
      });

      $("body").on("click", ".js-select-projekt-sentiment", function(event) {
        App.ProjektSelector.selectProjektSentiment($(event.currentTarget));
      });

      App.ProjektSelector.preselectProjektPhase();

      // Accessibility fixes
      $("body").on("keyup", ".js-toggle-projekt-group", function(event) {
        if ([13, 36, 37, 38, 39, 40].includes(event.which)) {
          event.stopPropagation();
          App.ProjektSelector.accessibilityProjektSelector(event.currentTarget, event);
        }
      });

      $("body").on("keyup", ".js-select-projekt", function(event) {
        if (event.which === 13 || event.which === 38 || event.which === 40) {
          event.stopPropagation();
          App.ProjektSelector.accessibilityProjekt(event.currentTarget, event);
        }
      });

      this.storeDefaultFormTitle();
      this.initialized = true;
    }
  };
}).call(this);
