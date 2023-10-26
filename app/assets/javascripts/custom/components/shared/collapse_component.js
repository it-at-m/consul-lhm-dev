
(function() {
  "use strict";
  App.CollapseComponent = {
    initialized: false,

    initialize: function() {
      if (!this.initialized) {
        $(document).on("click", ".js-collapse-head", this.toggleCollapse.bind(this));
      }

      this.initialized = true;
    },

    toggleCollapse: function(e) {
      var parentElement = e.currentTarget.parentElement;
      parentElement.classList.toggle("-opened");

      // $(parentElement).find(".js-collapse-body").slideToggle();
    }
  };
}).call(this);
