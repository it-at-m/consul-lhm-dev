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

        $('[id$="projekt_id"]').val(projektId)

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

      if ( $selectedProjekt.data('showMap') ) {
        $('#map-container').show();
        App.ProjektSelector.replaceProjektMapOnProposalCreation($selectedProjekt)
      } else {
        $('#map-container').hide();
      }

      App.ProjektSelector.toggleImageAttachment($selectedProjekt)
      App.ProjektSelector.toggleDocumentAttachment($selectedProjekt)
      App.ProjektSelector.toggleSummary($selectedProjekt)
      App.ProjektSelector.toggleExternalVideoUrl($selectedProjekt)
      App.ProjektSelector.updateAvailableTagsSelection($selectedProjekt)
      App.ProjektSelector.updateAvailableSDGsSelection($selectedProjekt)
      App.ProjektSelector.toggleExternalFieldsHeader($selectedProjekt)
      App.ProjektSelector.updateMainHeader($selectedProjekt)
      App.ProjektSelector.updateProjektLabelSelector($selectedProjekt)

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

    replaceProjektMapOnProposalCreation: function($projekt) {

      App.Map.destroy();

      if ( $projekt.data('showMap') ) {
        $('#map-container').show();

        $.ajax("/projekts/" + $projekt.data('projektId') + "/map_html", {
          type: "GET",
          dataType: "html",
          success: function(data) {
            App.Map.destroy();
            $('div.map_location.map').first().replaceWith(data)
            App.Map.initialize();
            App.Map.maps[0].setView([$projekt.data('latitude'), $projekt.data('longitude')], $projekt.data('zoom')).invalidateSize();
          }
        });

      } else {
        $('#map-container').hide();

      }
    },

    updateAvailableTagsSelection: function($projekt) {
      $('[id$=_tag_list_predefined]').val('')

      if ( $projekt.data('allow-tags') ) {
        $('#category_tags').show();
        $('#category_tags a').show();

        if ( $projekt.data("tag-ids") ) {
          $('#category_tags a').each(function() {
            if ( !$projekt.data("tag-ids").toString().split(',').includes($(this).data('categoryId').toString()) ) {
              $(this).hide();
            }
          })
        }

      } else {
        $('#category_tags').hide();
      }

    },

    updateAvailableSDGsSelection: function($projekt) {
      // $('[id$=_tag_list_predefined]').val('')

      if ( $projekt.data('allow-sdgs') ) {
        $('#sdgs-selector').show();
        $('#sdgs-selector label[for*=_sdg_goal_ids_]').show();

        if ( $projekt.data("sdg-ids") ) {
          $('#sdgs-selector label[for*=_sdg_goal_ids_]').each(function() {
            if ( !$projekt.data("sdg-ids").toString().split(',').includes($(this).data('sdgGoalId').toString()) ) {
              $(this).hide();
            }
          })
        }

      } else {
        $('#sdgs-selector').hide();
      }
    },

    updateProjektLabelSelector: function ($projekt) {
      if ($projekt.data("projekt-label-ids")) {
        var labelIdsToShow = $projekt.data("projekt-label-ids").toString().split(",");
      } else {
        var labelIdsToShow = [];
      }

      if (labelIdsToShow.join().length == 0) {
        $('#label-for-projekt-labels-selector').addClass('hide');
      } else {
        $('#label-for-projekt-labels-selector').removeClass('hide');
      }

      $("#projekt_labels_selector .projekt-label").each(function(index, label) {
        if (labelIdsToShow.includes($(label).data("labelId").toString())) {
          $(label).removeClass('hide');
        } else {
          $(label).addClass('hide');
        }
      });
    },

    toggleImageAttachment: function($projekt) {
      if ( $projekt.data('allowAttachedImage') ) {
        $('#attach-image').show();
      } else {
        $('#attach-image #nested-image .direct-upload').remove();
        $("#new_image_link").removeClass("hide");
        $('#attach-image').hide();
      }
    },

    toggleDocumentAttachment: function($projekt) {
      if ( $projekt.data('allowAttachedDocument') ) {
        $('#attach-documents').show();
      } else {
        $('#attach-documents').hide();
      }
    },

    toggleSummary: function($projekt) {
      if ( $projekt.data('showSummary') ) {
        $('.summary-field').show();
      } else {
        $('.summary-field').hide();
      }
    },

    toggleExternalVideoUrl: function($projekt) {
      if ( $projekt.data('allowVideo') ) {
        $('#external-video-url-fields').show();
      } else {
        $('#external-video-url-fields').hide();
      }
    },

    toggleExternalFieldsHeader: function($selectedProjekt) {
      if (
        $('#on-behalf-of-fields').length == 0 &&
          $('#attach-documents').is(":hidden") &&
          $('.summary-field').is(":hidden") &&
          $('#external-video-url-fields').is(":hidden") &&
          $('#category_tags').is(":hidden") &&
          $('#sdgs-selector').is(":hidden")
      ) {
        $('#additional-fields-title').hide();
      } else {
        $('#additional-fields-title').show();
      }
    },

    updateMainHeader: function($selectedProjekt) {
      var $header = $('header h1').first();
      var defaultText, customText;

      if (!$header.data("defaultText")) {
        defaultText = $header.text();
        $header.data("defaultText", defaultText)
      }

      if ($selectedProjekt.data('resourceFormTitle')) {
        customText = $selectedProjekt.data('resourceFormTitle').replaceAll('_', ' ')
        $header.text(customText);
      } else if ($header.data('defaultText')) {
        defaultText = $header.data('defaultText');
        $header.text(defaultText);
      }
    },

    preselectProjekt: function() {
      // get preselcted projekt id
      var selectedProjektId;
      var url = new URL(window.location.href);
      if (url.searchParams.get('projekt_id')) {
        selectedProjektId = url.searchParams.get('projekt_id');
      } else {
        selectedProjektId = $('[id$="projekt_id"]').val();
      }

      if ( selectedProjektId === '' ) {
        return false;
      }

      // get ordered array of parent projekts
      var projektIdsToShow = [selectedProjektId]
      var $selectedProjekt = $('#projekt_' + selectedProjektId)

      while ( $selectedProjekt.data('parentId') ) {
        projektIdsToShow.unshift( $selectedProjekt.data('parentId') )
        $selectedProjekt = $('#projekt_' + $selectedProjekt.data('parentId'))
      }

      // show projekts staring with top parent
      $.each(projektIdsToShow, function(index, projektId) {
        var $selectedProjekt = $('#projekt_' + projektId)
        App.ProjektSelector.selectProjekt($selectedProjekt);
        $selectedProjekt.closest('.projekt_group').hide();
      });

      if ( $selectedProjekt.data('hideProjektSelector') ) {
        $('#projekt-selector-block').prev('legend').hide();
        $('#projekt-selector-block').hide();
      }
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

      $(".js-new-resource").on("click", function(event) {
        if ( $(event.target).closest('.js-toggle-projekt-group').length == 0 ) {
          $('.projekt_group').hide();
        }
      });

      $("body").on("click", ".js-select-projekt-label", function() {
        App.ProjektSelector.selectLabel($(this));
      });

      App.ProjektSelector.preselectProjekt();

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
