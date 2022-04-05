(function() {
  "use strict";
  App.FooterPhasesComponentCustom = {
    initialize: function() {
      $('.js-sidebar-phase-link').on('click', function() {
        $("html, body").animate({
          scrollTop: $("#filter-subnav").offset().top
        });

        $("#footer-content").addClass("show-loader");
      })

      var navTotalSize = $('.filter-subnav .page-subnav-tab').length

      var leftArrow = $('.legislation-process-list .js-left-arrow-control')
      var rightArrow = $('.legislation-process-list .js-right-arrow-control')

      $('.js-sidebar-phase-link').on("ajax:complete", function (e, data){
        var index = Number.parseInt(e.currentTarget.dataset.index);
        var tabFilterSubnav = document.querySelector('#filter-subnav')

        $("#filter-subnav").get(0).scrollLeft = index * 270


        var maxScroll = tabFilterSubnav.scrollWidth - tabFilterSubnav.clientWidth

        if ( $('#filter-subnav').scrollLeft() != maxScroll) {
          $('#right-arrow-control').removeClass('disabled')
        }

        if ( maxScroll != 0 ) {
          $('#left-arrow-control').removeClass('disabled')
        }

        if ( maxScroll <= $('#filter-subnav').scrollLeft() + 240 ) {
          $('#right-arrow-control').addClass('disabled')
        }
        if ( $('#filter-subnav').scrollLeft() <= 240 ) {
          $('#left-arrow-control').addClass('disabled')
        }
      })
    }
  }
}).call(this);
