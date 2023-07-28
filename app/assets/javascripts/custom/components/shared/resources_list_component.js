(function() {
  "use strict";
  App.ResourcesListComponent = {
    WIDE_MODE_CLASS: "-wide",
    initialized: false,

    initialize: function() {
      if (this.initialized) {
        return;
      }

      $(document).on("click", ".js-resource-list-switch-view-button",
        this.switchResourceViewMode.bind(this)
      );

      this.initialized = true;
    },

    switchViewModeButton: function() {
      return $(".js-resource-list-switch-view-button");
    },

    switchResourceViewMode: function(e) {
      var switchButton = e.currentTarget;

      switchButton
        .closest(".resources-list")
        .classList.toggle(this.WIDE_MODE_CLASS);

      var switchButtonIcon = switchButton.querySelector("i");

      switchButtonIcon.classList.toggle("fa-grip-vertical");
      switchButtonIcon.classList.toggle("fa-bars");
    }
  };
}).call(this);
