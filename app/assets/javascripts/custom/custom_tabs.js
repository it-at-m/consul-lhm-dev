(function() {
  "use strict";
  App.CustomTabs = {
    initialize: function() {
      console.log("Custom tabs init")
      $(".js-custom-tab").on("click", function(event) {
        event.preventDefault();
        // var targetId = $(this).data('target');
        // navigator.clipboard.writeText( $('#' + targetId).html().trim() );
      });
    }
  };
}).call(this);
