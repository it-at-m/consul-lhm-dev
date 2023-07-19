(function() {
  "use strict";
  App.OrbitInPopupFixCustom = {
    initialize: function() {
      $('.reveal').on('open.zf.reveal', function(event) {
        if ( $(event.currentTarget).find('.orbit').length == 0 ) {
          return
        };

        var revealElement = $(event.currentTarget).find('.orbit').first()

        new Foundation.Orbit(revealElement)
      })


      $('[data-accordion]').on('down.zf.accordion', function(event, element){
        element.find('.orbit-container').each(function(index, element){
          $(element).css('height', '550px')
        })
      });
    }
  }
}).call(this);
