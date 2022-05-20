(function() {
  "use strict";
  App.CustomAdmin = {
    initialize: function() {

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

    }
  };

}).call(this);
