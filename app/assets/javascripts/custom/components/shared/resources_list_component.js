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
        this.handleSwitchResourceViewMode.bind(this)
      );

      this.initialized = true;
    },

    switchViewModeButton: function() {
      return $(".js-resource-list-switch-view-button");
    },

    handleSwitchResourceViewMode: function(e) {
      var switchButton = e.currentTarget;

      var resourcesList =
            switchButton
              .closest(".js-resources-list")

      var currentViewModeWide =
        this.isResourcesListInWideMode(resourcesList)
        resourcesList.dataset

      if (currentViewModeWide) {
        document.cookie = 'wide_resources=false'
      }
      else {
        document.cookie = 'wide_resources=true'
      }

      this.switchViewModeForRestResources();
    },

    switchViewModeForRestResources: function() {
      var resourcesListsOnPage = Array.from(document.querySelectorAll(".js-resources-list"));

      resourcesListsOnPage.forEach(function(resourcesList) {
        this.switchResourceListViewMode(resourcesList);
      }.bind(this))
    },

    isResourcesListInWideMode: function(resourcesList) {
      return resourcesList.classList.contains(this.WIDE_MODE_CLASS)
    },

    switchResourceListViewMode: function(resourcesList) {
      resourcesList.classList.toggle(this.WIDE_MODE_CLASS);
      var switchButton = resourcesList.querySelector(".js-resource-list-switch-view-button")

      var switchButtonIcon = switchButton.querySelector("i");

      switchButtonIcon.classList.toggle("fa-grip-vertical");
      switchButtonIcon.classList.toggle("fa-bars");
    }
  };
}).call(this);
