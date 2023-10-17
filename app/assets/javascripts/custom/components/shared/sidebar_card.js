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
      var sidebarCard = e.currentTarget.parent;

      // sidebarCard.querySelector("")
    }
  };
}).call(this);

