(function() {
  "use strict";
  App.ModerationCustom = {
    initialize: function() {
      $("body").on("click", ".js-only-with-flags", function() {
        var url = new URL(window.location.href);
        url.searchParams.set('only_with_flags', $(this).is(":checked"))
        url.searchParams.set('page', '1')
        window.history.pushState('', '', url)
        window.location.href = url.href;
      });
    }
  }
}).call(this);
