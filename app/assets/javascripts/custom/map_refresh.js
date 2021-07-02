(function() {
  "use strict";
  App.MapRefresh = {
    initialize: function() {
      $("#projekt-footer-tabs, #projekt-activity-tabs").on("change.zf.tabs", function() {
        if ($("#tab-activities:visible").length) {
          App.Map.destroy();
          App.Map.initialize();
        }
      });

      $("#projekts-tabs, #edit-projekt-tabs").on("change.zf.tabs", function() {
        if ($("#tab-projekt-map:visible").length) {
          App.Map.destroy();
          App.Map.initialize();
        }
      });
    }
  };
}).call(this);
