(function() {
  "use strict";
  App.CustomPages = {
    initialize: function() {
      var tabFilterSubnav = document.getElementById('filter-subnav')

      if (tabFilterSubnav) {

        var scrollLeftWidth = $('.page-subnav-tab.is-active').offset().left - tabFilterSubnav.clientWidth

        if (scrollLeftWidth > 0) {
          $('#left-arrow-control').removeClass('disabled')
          $('#filter-subnav').animate( { scrollLeft: scrollLeftWidth + 400 }, 10 );
        }
      }

      $("body").on("click", ".js-icon-toggle-budget-phases", function(event) {
        var $phase = $(this).closest('.sidebar-projekt-phase')
        $phase.attr('aria-expanded', function (i, attr) {
          return attr == 'true' ? 'false' : 'true'
        });

        $(this).attr('aria-expanded', $phase.attr('aria-expanded'))
      })

      $("body").on("click", ".js-left-arrow-control", function(event) {
        $('#filter-subnav').animate( { scrollLeft: '-=240' }, 500 );

        var tabFilterSubnav = document.getElementById('filter-subnav')
        var maxScroll = tabFilterSubnav.scrollWidth - tabFilterSubnav.clientWidth

        if ( $('#filter-subnav').scrollLeft() <= 240 ) {
          $('#left-arrow-control').addClass('disabled')
        }

        if ( $('#filter-subnav').scrollLeft() != maxScroll) {
          $('#right-arrow-control').removeClass('disabled')
        }
      })

      $("body").on("click", ".js-right-arrow-control", function(event) {
        $('#filter-subnav').animate( { scrollLeft: '+=240' }, 500 );

        var tabFilterSubnav = document.getElementById('filter-subnav')
        var maxScroll = tabFilterSubnav.scrollWidth - tabFilterSubnav.clientWidth

        if ( maxScroll != 0 ) {
          $('#left-arrow-control').removeClass('disabled')
        }

        if ( maxScroll <= $('#filter-subnav').scrollLeft() + 240 ) {
          $('#right-arrow-control').addClass('disabled')
        }

      })

      $("body").on("click", ".spinner-placeholder ul.pagination li a", function(event) {
        $(".spinner-placeholder").addClass("show-loader")
      })
    }
  }
}).call(this);
