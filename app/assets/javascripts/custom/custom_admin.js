(function() {
  "use strict";
  App.CustomAdmin = {
    updateVotationTypeHint: function(newVotationTypeName) {
      $('span.votation-type-hint').each(function() {
       $(this).addClass('hide');
      });


      var visibleHintId = '#votation-type-' + newVotationTypeName;
      $(visibleHintId).removeClass('hide')
    },

    toggleVotationTypeMaxVotesField: function(newVotationTypeName) {
      var typesAllowingMultipleAnswers = ['multiple', 'multiple_with_weights']

      if ( typesAllowingMultipleAnswers.includes(newVotationTypeName) ) {
        $('#votation_max_votes').removeClass('hide')
      } else {
        $('#votation_max_votes').addClass('hide')
      }
    },

    initialize: function() {
      $("body").on("click", ".js-update-votation-type-hint", function() {
        var newVotationTypeName = event.target.value;
        App.CustomAdmin.updateVotationTypeHint(newVotationTypeName);
        App.CustomAdmin.toggleVotationTypeMaxVotesField(newVotationTypeName);
      })

      $("body").on("click", ".js-map-layer-base-checkbox", function() {
        var $base_checkbox = $(this)
        var $show_by_default_chechbox = $base_checkbox.closest('.checkboxes').find('#map_layer_show_by_default')

        if ( $base_checkbox.is(':checked') ) {
          $show_by_default_chechbox.prop('checked', false);
          $show_by_default_chechbox.attr("disabled", true);
        } else {
          $show_by_default_chechbox.removeAttr("disabled");
        }
      })

      $("body").on("click", ".js-map-protocol", function() {
        var $selectedRadioButton = $(this)
        var $transparentCheckbox = $selectedRadioButton.closest('.map-layer-form').find('#map_layer_transparent')
        var $layerNamesInput = $selectedRadioButton.closest('.map-layer-form').find('#map_layer_layer_names')

        if ( $selectedRadioButton.val() == 'regular' ) {
          $transparentCheckbox.prop("checked", false);
          $transparentCheckbox.attr("disabled", true);
          $layerNamesInput.attr("disabled", true);
  
        } else if ( $selectedRadioButton.val() == 'wms' ) {
          $transparentCheckbox.removeAttr("disabled");
          $layerNamesInput.removeAttr("disabled");
        }
      })

      $(document).on("click", ".js-admin-edit-projekt-event", function(e) {
        App.HTMLEditor.initialize();
      })
    }
  };

}).call(this);
