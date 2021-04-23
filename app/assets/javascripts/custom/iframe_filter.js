(function() {
  "use strict";
  App.IframeFilter = {
    blurIframes: function() {
      var expainerText = "<div class='iframe-explainer'><p class='iframe-explainer-text'>Mit dem Aufruf des Inhaltes erklären Sie sich einverstanden, dass Ihre Daten an Drittanbieter übermittelt werden und das Sie die Datenschutzerklärung gelesen haben.</p><a href='' class='js-iframe-consent-button iframe-consent-button'>Akzeptieren</a></div>"

      $('iframe').each( function() {
        $(this).css('filter', 'blur(5px)')
        $(this).wrap( "<div class='iframe-wrapper'></div>" );
        $(this).after( expainerText )
      })
    },

    initialize: function() {
      if ( document.querySelector("meta[name='two-click-iframes']").getAttribute("content") === 'active' ) {
        App.IframeFilter.blurIframes();

        $("body").on("click", ".js-iframe-consent-button", function(event) {
          event.preventDefault();
          $(this).closest('.iframe-wrapper').find('iframe').css('filter', 'none')
          $(this).closest('.iframe-explainer').hide();
        });
      }
    }
  }
}).call(this);
