(function() {
  "use strict";
  App.Geozones = {

    updateLabelStyle: function($label) {
      $('#filter-geozones li').each( function() {
        $(this).removeClass('label-selected');
      })      

      $label.closest('li').addClass('label-selected')
    },

    updateGeozoneRestrictionsParam: function($label) {
      var url = new URL(window.location.href);
      var selection = $('input[name="geozone_restriction"]:checked').val();
      url.searchParams.set('geozone_restriction', selection)
      window.history.pushState('', '', url)
    },

    updateGeozonesParams: function() {
      var url = new URL(window.location.href);
      var selected_geozones = [];
      $("ul#geozones-list input:checkbox:checked").each( function() {
        selected_geozones.push($(this).val())
      });

      if (selected_geozones.length) {
        url.searchParams.set('geozones', selected_geozones.join(','))
      } else {
        url.searchParams.delete('geozones')
      };

      window.history.pushState('', '', url);
    },

    initialize: function() {

      $("body").on("click", ".js-filter-geozone-restriction", function() {
        var $label = $(this).closest('label');
        App.Geozones.updateLabelStyle($label);
        App.Geozones.updateGeozoneRestrictionsParam($label);
      });

      $("body").on("click", ".js-filter-geozones", function() {
        App.Geozones.updateGeozonesParams();
      });

      $("body").on("click", ".js-apply-geozone-filter", function() {
        var url = new URL(window.location.href);
        window.location.href = url;
      });

      $("body").on("click", ".js-show-all-geozones", function(event) {
        event.preventDefault();
        $(this).parent().siblings('li').each(function() { 
          $(this).removeClass('hide');
        })
        $(this).addClass('hide');
      });

      $("body").on("click", ".js-reset-geozone-filter", function() {
        var url = new URL(window.location.href);

        if (url.searchParams.get('geozones')) {
          url.searchParams.delete('geozones');
        }

        $('#filter-geozones input').each(
          function() {
            $(this).prop('checked', false);
          }
        )

        $('#filter-geozones li').each(
          function() {
            $(this).removeClass('label-selected');
          }
        )

        url.searchParams.delete('geozones');
        url.searchParams.set('geozone_restriction', 'all_resources');
        $('#filter-geozones li').first().addClass('label-selected');
        $('#filter-geozones li input[type="radio"]').first().prop("checked", true);

        window.history.pushState('', '', url)
        //window.location.href = url;
      });

    }
  };
}).call(this);
