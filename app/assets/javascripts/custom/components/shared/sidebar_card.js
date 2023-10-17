(function() {
  "use strict";
  App.SidebarCardComponent = {
    initialized: false,

    initialize: function() {
      if (this.initialized) {
        return;
      }

      $(document).on("click", ".js-sidebar-card--title", this.toggleContent.bind(this));

      this.initialized = true;
    },

    toggleContent: function(e) {
      var $sidebarCard = $(e.currentTarget.closest(".sidebar-card"));

      if (window.screen.width <= 970) {
        var $content = $sidebarCard.find(".sidebar-card--content");
        $content.toggle();
        $sidebarCard.find(".icon-chevron-down").toggleClass("-rotated");
      }
    }
  };
}).call(this);

