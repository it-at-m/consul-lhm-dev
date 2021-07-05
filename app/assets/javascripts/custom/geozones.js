(function() {
  "use strict";
  App.Geozones = {

    updateLabelStyle: function($label) {
      $label.closest('ul').find('li.label-selected').each( function() {
        $(this).removeClass('label-selected');
      })      

      $label.closest('li').addClass('label-selected')
    },

    updateGeozoneAffiliationParam: function($label) {
      var url = new URL(window.location.href);
      var selection = $('input[name="geozone_affiliation"]:checked').val();
      url.searchParams.set('geozone_affiliation', selection)
      url.searchParams.delete('affiliated_geozones')
      url.searchParams.delete('search')
      window.history.pushState('', '', url)
      window.location.href = url;
    },

    updateGeozoneRestrictionParam: function($label) {
      var url = new URL(window.location.href);
      var selection = $('input[name="geozone_restriction"]:checked').val();
      url.searchParams.set('geozone_restriction', selection)
      url.searchParams.delete('restricted_geozones')
      url.searchParams.delete('search')
      window.history.pushState('', '', url)
      window.location.href = url;
    },

    updateGeozonesParams: function($radiobutton) {
      var geozone_filter = $radiobutton.closest("ul").attr('id')
      var geozone_filter_type = $radiobutton.closest('.geozone-filter').attr('id')
      var url = new URL(window.location.href);
      url.searchParams.set(geozone_filter, $radiobutton.val());
      url.searchParams.set(geozone_filter_type, 'only_geozones')
      url.searchParams.delete('search')
      window.history.pushState('', '', url);
      window.location.href = url;
    },

    initialize: function() {

      $("body").on("click", ".js-filter-geozone-affiliation", function() {
        var $label = $(this).closest('label');
        App.Geozones.updateLabelStyle($label);
        App.Geozones.updateGeozoneAffiliationParam($label);
      });

      $("body").on("click", ".js-filter-geozone-restriction", function() {
        var $label = $(this).closest('label');
        App.Geozones.updateLabelStyle($label);
        App.Geozones.updateGeozoneRestrictionParam($label);
      });

      $("body").on("click", ".js-toggle-geozones", function() {
        event.preventDefault();
        var $label = $(this).closest('label');

        var $wrapper = $label.closest('li');
        if ($wrapper.attr("aria-expanded") != "true") {
          $wrapper.attr("aria-expanded","true")
        } else {
          $wrapper.attr("aria-expanded","false")
        }
      })

      $("body").on("click", ".js-filter-geozones", function() {
        var $radiobutton = $(this)
        var $label = $(this).closest('label');
        App.Geozones.updateLabelStyle($label);

        $label.closest('.geozone-filter').find('ul').first().children('li.label-selected').each( function() {
          $(this).removeClass('label-selected');
        })

        App.Geozones.updateGeozonesParams($radiobutton);
      });

      $("body").on("click", ".js-show-all-geozones", function(event) {
        event.preventDefault();
        $(this).parent().siblings('li').each(function() { 
          $(this).removeClass('hide');
        })
        $(this).addClass('hide');
      });
    }
  };
}).call(this);
