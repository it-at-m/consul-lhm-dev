(function() {
  "use strict";
  App.ProjektSelector = {

    toggleProjektGroup: function(selector) {
      if (selector.dataset.target) {
        var target_projekt_group_id = selector.dataset.target
        $(target_projekt_group_id).toggle()
      }
    },

    selectProjekt: function($projekt) {
      var $selectedProjekt = $projekt.clone().removeClass('js-select-projekt')
      var projektId = $projekt.data('projektId')
      var $currentProjektSelector = $projekt.closest('.projekt-selector')
      var $nextProejektSelector = $currentProjektSelector.nextAll('.projekt-selector').first()
      var $nextSpacer = $currentProjektSelector.next()


      App.ProjektSelector.resetNextSelectors($currentProjektSelector)

      // replace placeholder with projekt
      $currentProjektSelector.find('.selected-projekt').first().hide();
      $currentProjektSelector.children('.projekt').remove();
      $currentProjektSelector.prepend( $selectedProjekt )

      // show next selector
      if ( $selectedProjekt.data('projektSelectableChildren') ) {
        $nextSpacer.css('visibility', 'visible')
        $nextProejektSelector.css('visibility', 'visible')
        $nextProejektSelector.attr('data-target', '#group-for-' + projektId)
        $nextProejektSelector.children('.projekt_group').hide()
      }

      // conditionally toggle next group to select
      if ( !$selectedProjekt.data('projektSelectable') ) {
        $('#group-for-' + projektId).show();
      }

      // update selected projekt
      if ( $selectedProjekt.data('projektSelectable') ) {
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

      App.ProjektSelector.updatePhasesSelector(projektId)

      // reset form when projekt changes TODO
      $('[id$="projekt_phase_id"]').val('')
      $('#map-container').hide();
    },

    selectProjektPhase: function($projektPhase) {
      var projektPhaseId = $projektPhase.data('projektPhaseId')
      $('[id$="projekt_phase_id"]').val(projektPhaseId)

      if ( $("span#persisted-resource-data").length ) {
        var persistedResourceData = $("span#persisted-resource-data").data();

        if ( persistedResourceData['resourceMap'] ) {
          $('#map-container').show();
        }

      } else {
        replaceProjektMapOnResourceCreation($projektPhase);
      }

      updateProjektSelectorHint(projektPhaseId);
      updateFormHeading(projektPhaseId);
      updateActivePhaseSelector(projektPhaseId);
      toggleImageAttachment($projektPhase);
      toggleDocumentAttachment($projektPhase);
      toggleSummary($projektPhase);
      toggleExternalVideoUrl($projektPhase);
      toggleOnBehalfOf($projektPhase);
      toggleExternalFieldsHeader($projektPhase);
      toggleTagging($projektPhase);

      function updateProjektSelectorHint(projektPhaseId) {
        var $hintElement = $('[id$="_creation_recommendations"]').first();
        if (!$hintElement.length) {
          return;
        }

        $.ajax("/projekt_phases/" + projektPhaseId + "/selector_hint_html", {
          type: "GET",
          dataType: "html",
          success: function(data) {
            $hintElement.html(data);
            $(document).foundation()
          }
        });
      }

      function updateFormHeading(projektPhaseId) {
        if ( $('.admin-content').length ) {
          return
        }

        var $header = $('header h1').first();

        $.ajax("/projekt_phases/" + projektPhaseId + "/form_heading_text", {
          type: "GET",
          dataType: "html",
          success: function(data) {
            $header.text(data);
            $(document).foundation()
          }
        });
      }

      function updateActivePhaseSelector(projektPhaseId) {
        $('.projekt-phase-selector').removeClass('active');
        $('#projekt-phase-selector-' + projektPhaseId).addClass('active');
      }

      function replaceProjektMapOnResourceCreation($projektPhase) {
        App.Map.destroy();

        if ( $projektPhase.data('showMap') ) {
          $('#map-container').show();

          $.ajax("/projekt_phases/" + $projektPhase.data('projektPhaseId') + "/map_html", {
            type: "GET",
            dataType: "html",
            success: function(data) {
              if ( $projektPhase.data('vcMap') ) {
                $('div.map_location.map').first().replaceWith(data)
                App.VCMap.initialize();
              } else {
                App.Map.destroy();
                $('div.map_location.map').first().replaceWith(data)
                App.Map.initialize();
                App.Map.maps[0].setView([$projektPhase.data('latitude'), $projektPhase.data('longitude')], $projektPhase.data('zoom')).invalidateSize();
              }
            }
          });
        } else {
          $('#map-container').hide();
        }
      }

      function toggleImageAttachment($projektPhase) {
        if ( $projektPhase.data('allowAttachedImage') ) {
          $('#attach-image').show();
        } else {
          $('#attach-image #nested-image .direct-upload').remove();
          $("#new_image_link").removeClass("hide");
          $('#attach-image').hide();
        }
      }

      function toggleDocumentAttachment($projektPhase) {
        if ( $projektPhase.data('allowAttachedDocument') ) {
          $('#attach-documents').show();
        } else {
          $('#attach-documents').hide();
        }
      }

      function toggleSummary($projektPhase) {
        if ( $projektPhase.data('showSummary') ) {
          $('.summary-field').show();
        } else {
          $('.summary-field').hide();
        }
      }

      function toggleExternalVideoUrl($projektPhase) {
        if ( $projektPhase.data('allowVideo') ) {
          $('#external-video-url-fields').show();
        } else {
          $('#external-video-url-fields').hide();
        }
      }

      function toggleOnBehalfOf($projektPhase) {
        if ( $projektPhase.data('createOnBehalfOf') ) {
          $('#create-on-behalf-of').removeClass('hide');
        } else {
          $('#create-on-behalf-of').addClass('hide');
        }
      }

      function toggleExternalFieldsHeader($projektPhase) {
        if (
          $('#create-on-behalf-of').is(":hidden") &&
            $('#attach-documents').is(":hidden") &&
            (!$('#external-video-url-fields').length || $('#external-video-url-fields').is(":hidden"))
        ) {
          $('#additional-fields-title').hide();
        } else {
          $('#additional-fields-title').show();
        }
      }

      function toggleTagging($projektPhase) {
        if ($projektPhase.data("projekt-label-ids") || $projektPhase.data("sentiment-ids") ) {
          $('legend.tagging').removeClass('hide');
        } else {
          $('legend.tagging').addClass('hide');
        }

        updateProjektLabelSelector($projektPhase);
        updateSentimentSelector($projektPhase);
      }

      function updateProjektLabelSelector($projektPhase) {
        if ($projektPhase.data("projekt-labels-name")) {
          $('#projekt_labels_selector label[for$=_projekt_labels]').text($projektPhase.data("projekt-labels-name").replaceAll("_", " "));
        }

        if ($projektPhase.data("projekt-label-ids")) {
          var labelIdsToShow = $projektPhase.data("projekt-label-ids").toString().split(",");
        } else {
          var labelIdsToShow = [];
        }

        if (labelIdsToShow.join().length == 0) {
          $('#projekt_labels_selector').addClass('hide');
          $('#projekt_labels_selector input[type=checkbox]').prop('checked', false);

        } else {
          $('#projekt_labels_selector').removeClass('hide');
        }

        $("#projekt_labels_selector .projekt-label").each(function(index, label) {
          if (labelIdsToShow.includes($(label).data("labelId").toString())) {
            $(label).removeClass('hide');
          } else {
            $(label).addClass('hide');
          }
        });
      }

      function updateSentimentSelector($projektPhase) {
        if ($projektPhase.data("sentiments-name")) {
          $('#sentiment_selector label[for$=_sentiment_id]').text($projektPhase.data("sentiments-name").replaceAll("_", " "));
        }

        if ($projektPhase.data("sentiment-ids")) {
          var sentimentIdsToShow = $projektPhase.data("sentiment-ids").toString().split(",");
        } else {
          var sentimentIdsToShow = [];
        }

        if (sentimentIdsToShow.join().length == 0) {
          $('#sentiment_selector').addClass('hide');
          $('#sentiment_selector input[type=radio]').prop('checked', false);
        } else {
          $('#sentiment_selector').removeClass('hide');
        }

        $("#sentiment_selector .sentiment").each(function(index, sentiment) {
          if (sentimentIdsToShow.includes($(sentiment).data("sentimentId").toString())) {
            $(sentiment).removeClass('hide');
          } else {
            $(sentiment).addClass('hide');
          }
        })
      }
    },

    addNextProjektPlaceholder: function( $nextProejektSelector, text ) {
      var indexOfProjektSelector = $('.projekt-selector').index($nextProejektSelector)

      if (indexOfProjektSelector == 1) {
        $nextProejektSelector.find('.selected-projekt-placeholder').html("Wähle Kategorie " + text)
      } else if (indexOfProjektSelector == 2) {
        $nextProejektSelector.find('.selected-projekt-placeholder').html("Wähle Unterkategorie " + text)
      }
    },

    resetSelectedProjectStyles: function() {
      $('.projekt-selector > .projekt').css('background-color', '#CEE9F9')
      $('.projekt-selector > .projekt').css('color', '#0a0a0a')
      $('.projekt-selector').css('color', '#0a0a0a')
      $('.projekt-selector').children('.projekt').find('.projekt-icon .fas').css('color', '#222')
    },

    resetNextSelectors: function($selector) {
      $selector.nextAll().each( function() {
        $(this).css('visibility', 'hidden');
        $(this).find('.selected-projekt').show();
        $(this).children('.projekt').remove();
      })
    },

    updatePhasesSelector: function(projektId) {
      $('#projekt-phase-selector-fields').find(".projekt-phase-group").hide();
      $('#projekt-phase-group-for-projekt-' + projektId).show();
    },

    preselectProjektPhase: function() {
      // get preselcted projekt id
      var selectedProjektId;
      var selectedProjektPhaseId;
      var url = new URL(window.location.href);

      if (url.searchParams.get('projekt_phase_id')) {
        selectedProjektId = url.searchParams.get('projekt_id');
        selectedProjektPhaseId = url.searchParams.get('projekt_phase_id');
      } else {
        selectedProjektId = $('[id$="projekt_id"]').val();
        selectedProjektPhaseId = $('[id$="projekt_phase_id"]').val();
      }

      if ( selectedProjektId === '' || selectedProjektPhaseId === '' ) {
        return false;
      }

      // get ordered array of parent projekts
      var projektIdsToShow = [selectedProjektId]
      var $selectedProjekt = $('#projekt_' + selectedProjektId)

      while ( $selectedProjekt.data('parentId') ) {
        projektIdsToShow.unshift( $selectedProjekt.data('parentId') )
        $selectedProjekt = $('#projekt_' + $selectedProjekt.data('parentId'))
      }

      // show projekts staring with top parent and select projekt
      $.each(projektIdsToShow, function(index, projektId) {
        var $selectedProjekt = $('#projekt_' + projektId)
        App.ProjektSelector.selectProjekt($selectedProjekt);
        $selectedProjekt.closest('.projekt_group').hide();
      });

      // if ( $selectedProjekt.data('hideProjektSelector') ) {
      //   $('#projekt-selector-block').prev('legend').hide();
      //   $('#projekt-selector-block').hide();
      // }

      // select projekt phase
      var $selectedProjektPhase = $('#projekt-phase-selector-' + selectedProjektPhaseId)
      App.ProjektSelector.selectProjektPhase($selectedProjektPhase);
    },


    //accessibility functions

    accessibilityProjektSelector: function(selector) {
      // if group hidden and enter or down arrow pressed - toggle(show) grooup
      if ( !$(selector).children('.projekt_group:visible').length && (event.which == 13 || event.which == 40) ) {
        App.ProjektSelector.toggleProjektGroup(selector);
      }

      // if group visible and down arrow pressed - jump to grooup
      if ( $(selector).children('.projekt_group:visible').length && event.which == 40 ) {
        $(selector).children('.projekt_group:visible').first().find('.js-select-projekt').first().focus();
      }

      // if group visible and enter or up arrow pressed - toggle(hide) group
      if ( $(selector).children('.projekt_group:visible').length && (event.which == 13 || event.which == 38) ) {
        App.ProjektSelector.toggleProjektGroup(selector);
      }

      if ( event.which == 37 ) { // left arrow click
        $(selector).prevAll('.projekt-selector').first().focus();
        $(selector).prevAll('.projekt-selector').first().click();
        $(selector).children('.projekt_group:visible').hide();
      }

      if ( event.which == 39 ) { // right arrow click
        $(selector).nextAll('.projekt-selector').first().focus()
        $(selector).nextAll('.projekt-selector').first().click()
        $(selector).children('.projekt_group:visible').hide();
      }
    },

    accessibilityProjekt: function(projekt) {
      if ( event.which == 13 ) { // enter pressed
        $(projekt).click();
        $(projekt).closest('.projekt-selector').nextAll('.projekt-selector').first().focus();
      }

      if ( event.which == 40 ) { // down button pressed
        $(projekt).next().focus();
      }

      if ( event.which == 38 ) { // up button pressed
        if ( $(projekt).prev().length ) {
          $(projekt).prev().focus();
        } else {
          $(projekt).closest('.projekt-selector').focus();
        }
      }
    },

    selectLabel: function($label) {
      var labelId = $label.data('labelId');
      var $labelCheckBox = $("#projekt-labels-checkboxes [id*='_projekt_label_ids_" + labelId + "']");
      $labelCheckBox.prop("checked", !$labelCheckBox.prop("checked"));

      if ($labelCheckBox.prop("checked")) {
        var labelBackgroundColor = $label.data('backgroundColor');
        var labelTextColor = $label.data('textColor');
        $label.css('background-color', labelBackgroundColor);
        $label.css('color', labelTextColor);
      } else {
        $label.css('background-color', '#767676')
        $label.css('color', '#fff')
      }
    },

    initialize: function() {
      $("body").on("click", ".js-toggle-projekt-group", function(event) {
        App.ProjektSelector.toggleProjektGroup(this);
      });

      $("body").on("click", ".js-select-projekt", function(event) {
        App.ProjektSelector.selectProjekt($(this), true);
      });

      $("body").on("click", ".js-select-projekt-phase", function(event) {
        App.ProjektSelector.selectProjektPhase($(this), true);
      });

      $(".js-new-resource").on("click", function(event) {
        if ( $(event.target).closest('.js-toggle-projekt-group').length == 0 ) {
          $('.projekt-group').hide();
        }
      });

      $("body").on("click", ".js-select-projekt-label", function() {
        App.ProjektSelector.selectLabel($(this));
      });

      App.ProjektSelector.preselectProjektPhase();

      // Accessibility fixes
      $('body').on('keyup', '.js-toggle-projekt-group', function(event) {
        if ( [13, 36, 37, 38, 39, 40].includes(event.which) ) {
          event.stopPropagation();
          App.ProjektSelector.accessibilityProjektSelector(this);
        }
      });

      $('body').on('keyup', '.js-select-projekt', function(event) {
        if ( event.which === 13 || event.which === 38 || event.which === 40 ) {
          event.stopPropagation();
          App.ProjektSelector.accessibilityProjekt(this);
        }
      });
    }
  };
}).call(this);
