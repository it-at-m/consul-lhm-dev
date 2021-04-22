(function() {
  "use strict";
  App.ResponsiveMenu = {

    initialize: function() {

      $("body").on("click", ".js-toggle-mobile-flyout-item", function() {
        var $navElement = $(this).closest('.nav-element')
        var $navElementValue = ( $navElement.attr('aria-expanded') == 'true' )
        $navElement.attr('aria-expanded', !$navElementValue )
      });

    }
  };
}).call(this);
