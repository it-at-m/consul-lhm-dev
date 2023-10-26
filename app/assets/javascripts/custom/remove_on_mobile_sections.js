(function() {
  "use strict";
  App.RemoveOnMobileSections = {
    initialize: function() {
      // if (window.screen.width <= 640) {
      if (window.screen.width <= 970) {
        $(".js-remove-on-mobile-section").remove();
      } else {
        $(".js-remove-on-desktop-section").remove();
      }
    }
  };
}).call(this);
