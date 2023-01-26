(function() {
  "use strict";
  App.ProjektLabels = {

    selectLabel: function($label) {
      var labelId = $label.data('labelId');
      var $labelCheckBox = $("#projekt-labels [id*='_projekt_label_ids_" + labelId + "']");
      $labelCheckBox.prop("checked", !$labelCheckBox.prop("checked"));

      if ($labelCheckBox.prop("checked")) {
        var labelColor = $label.data('backgroundColor');
        $label.css('background-color', labelColor)
      } else {
        $label.css('background-color', '#767676')
      }
    },

    initialize: function() {
      $("body").on("click", ".js-select-projekt-label", function() {
        App.ProjektLabels.selectLabel($(this));
      });
    }
  }
}).call(this);
