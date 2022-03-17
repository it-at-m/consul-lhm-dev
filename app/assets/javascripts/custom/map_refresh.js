(function() {
  "use strict";
  App.MapRefresh = {
    initialize: function() {
      $("#projekts-tabs, #edit-projekt-tabs").on("change.zf.tabs", function() {
        if ($("#tab-projekt-map:visible").length) {
          $('#admin-map').foundation();
          App.Map.destroy();
          App.Map.initialize();
        }
      });
    }
  };
}).call(this);
