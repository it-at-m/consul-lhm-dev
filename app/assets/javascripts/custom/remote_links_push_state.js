(function() {
  "use strict";
  App.RemoteLinksPushState = {
    pushState: function(link) {
      history.pushState({ turbolinks: {} }, "", link)
    },

    initialize: function() {
      $("body").on("click", ".js-remote-link-push-state", function() {
        var link = $(this).data('footer-tab-back-url')
        App.RemoteLinksPushState.pushState(link);
      });

      $("body").on("click", "#footer-content ul.pagination li a[data-remote='true']", function() {
        var targetPage = new URL(event.target.href).searchParams.get('page')

        var link = new URL(window.location.href);
        link.searchParams.set('page', targetPage)

        App.RemoteLinksPushState.pushState(link);
      });
    }
  };
}).call(this);
