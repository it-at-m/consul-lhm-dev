(function() {
  "use strict";
  App.RemoteLinksPushState = {
    pushState: function(link) {
      history.pushState({ turbolinks: {} }, "", link)
    },

    initialize: function() {
      $("body").on("click", ".js-remote-link-push-state", function() {
        var link = $(this).data('footer-tab-back-url')
        this.pushState(link);
      }.bind(this));
    }
  };
}).call(this);
