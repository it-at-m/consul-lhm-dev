(function() {
  "use strict";
  App.OrbitInPopupFixCustom = {
    initialize: function() {
      $('.reveal').on('open.zf.reveal', function(event) {
        var revealElement = $(event.currentTarget).find('.orbit').first()

        new Foundation.Orbit(revealElement)
      })
    }
  }
}).call(this);
