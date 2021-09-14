(function() {
  "use strict";
  App.ResponsiveMenu = {

    toggleMenu: function($arrow) {
      console.log($arrow.prop('tagName') + '.' + $arrow.prop('className'))
      var $navElement = $arrow.closest('li.nav-element')
      var $navElementValue = ( $navElement.attr('aria-expanded') == 'true' )
      $navElement.attr('aria-expanded', !$navElementValue )
    },

    initialize: function() {

      $("body").on("click", ".js-toggle-mobile-flyout-item", function() {
        App.ResponsiveMenu.toggleMenu($(this))
      });

      $("body").on("keyup", ".js-toggle-mobile-flyout-item", function() {
        var $menuOpen = $(this).closest('.nav-element').attr('aria-expanded') == 'true'
        if ( ( event.which == 40 && !$menuOpen ) || // down arrow
             ( event.which == 38 && $menuOpen )  ) { // up arrow
          App.ResponsiveMenu.toggleMenu($(this))
        }

      });

      $("body").on("keyup", ".js-toggle-mobile-menu", function() {
        if ( event.which == 32 || event.which == 13 ) {
          event.preventDefault();
          $('#responsive-menu').toggle();
          var menuVisible = $('#responsive-menu').is(':visible');
          $(this).attr('aria-expanded', menuVisible);
        }
      });

    }
  };
}).call(this);
