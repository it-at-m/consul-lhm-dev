(function() {
  "use strict";
  App.ProjektLabels = {

    selectLabel: function($label) {
      $label.css('background-color', $label.data('backgroundColor'))
    },

    initialize: function() {
      $("body").on("click", ".js-select-projekt-label", function() {
        App.ProjektLabels.selectLabel($(this));
      });
    }
  }
}).call(this);
