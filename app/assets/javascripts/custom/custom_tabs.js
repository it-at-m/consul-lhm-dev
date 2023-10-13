(function() {
  "use strict";
  App.CustomTabs = {
    initialize: function() {
      console.log("Custom tabs init")
      $(".js-custom-tab").on("click", function(event) {
        event.preventDefault();
        var tabContentId = event.currentTarget.dataset.contentId;
        var tabContent = document.getElementById(tabContentId);
        $(".js-custom-tab-content").removeClass("-visible");
        tabContent.classList.add("-visible");
      });
    }
  };
}).call(this);
