(function() {
  "use strict";
  App.Projekts = {

    // Functions for selectors in form

    toggleChildProjekts: function($label) {
      var projektId = $label.data()['projektId']
      var dataParentIdentifierString = "[data-parent=\"" + projektId + "\"]"
      var $childrenProjektsGroup = $( dataParentIdentifierString )

      if ( $childrenProjektsGroup.is(":hidden") ) {
        App.Projekts.hideCurrentlyVisibleChildProjekts($label);
        $childrenProjektsGroup.show()
      } else {
        App.Projekts.hideCurrentlyVisibleChildProjekts($label);
      }
    },

    highlightLabel: function($label) {
      $label.closest('.projekt-tags-column').find('label').each( function() {
        $(this).removeClass('highlighted')
      })
      $label.addClass('highlighted')
    },

    hideCurrentlyVisibleChildProjekts: function($label) {
      var $currentProjektGroup = $label.parent();
      var $currentColumn = $label.parent().parent()

      $currentColumn.nextAll().each(function() {
        $(this).find(".projekt-group").each( function() {
          $(this).hide();
        })
      })
    },

    // Functions for selectors in sidebar

    toggleChildrenInSidebar: function($label) {
      $label.attr('aria-expanded', function (i, attr) {
        return attr == 'true' ? 'false' : 'true'
      });
    },

    formNewFilterProjektsRequest: function($checkbox) {

      var url = new URL(window.location.href);
      var selectedProjektIds;
      var $label = $checkbox.parent()
      var $filterArrow = $label.siblings('.projekt-arrow').first()

      if (url.searchParams.get('projekts')) {
        selectedProjektIds = url.searchParams.get('projekts').split(',');
      } else {
        selectedProjektIds = [];
      }

      if ( $checkbox.is(':checked') ) {
        selectedProjektIds.push($checkbox.val());
        $label.css('color', '#06408E')
        $filterArrow.css('border-color', '#06408E')

      } else {
        var index = selectedProjektIds.indexOf($checkbox.val());
        if (index > -1) {
          selectedProjektIds.splice(index, 1);
        }
        $label.css('color', '#878787')
        $filterArrow.css('border-color', '#C6C6C6')
      }

      var uniqueProjektIds = selectedProjektIds.filter( function(v, i, a) { return  a.indexOf(v) === i } );

      if ( uniqueProjektIds.length > 0) {
        url.searchParams.set('projekts', uniqueProjektIds.join(','))
      }  else {
        url.searchParams.delete('projekts')
      }

      window.history.pushState('', '', url)
    },

    // Functions for filtering by combination of projects, categories, and user tags

    modifyFilterParams: function(clickedLink) {
      var currentPageUrl = new URL(window.location.href);
      var currentProjektIds;
      var currentGeoZoneRestriction;
      var currentGeoZoneIds;
      var currentTags;

      if (currentPageUrl.searchParams.get('projekts')) {
        currentProjektIds = currentPageUrl.searchParams.get('projekts').split(',');
      } else {
        currentProjektIds = [];
      }

      if (currentPageUrl.searchParams.get('geozone_restriction')) {
        currentGeoZoneRestriction = currentPageUrl.searchParams.get('geozone_restriction');
      } else {
        currentGeoZoneRestriction = '';
      }

      if (currentPageUrl.searchParams.get('geozones')) {
        currentGeoZoneIds = currentPageUrl.searchParams.get('geozones').split(',');
      } else {
        currentGeoZoneIds = [];
      }

      if (currentPageUrl.searchParams.get('tags')) {
        currentTags = currentPageUrl.searchParams.get('tags').split(',');
      } else {
        currentTags = [];
      }

      if (currentPageUrl.searchParams.get('page')) {
        currentPageUrl.searchParams.delete('page');
      }

      var clickedUrl = new URL(clickedLink);
      var newProjektId;
      var newGeoZoneRestriction;
      var newGeoZoneId;
      var newTag;

      if (clickedUrl.searchParams.get('projekts')) {
        newProjektId = clickedUrl.searchParams.get('projekts').split(',')[0];

        if (currentProjektIds.includes(newProjektId)) {
          var index = currentProjektIds.indexOf(newProjektId);
          if (index > -1) {
            currentProjektIds.splice(index, 1);
          }
          currentPageUrl.searchParams.set('projekts', currentProjektIds.join(','))
        } else {
          currentProjektIds.push(newProjektId)
          currentProjektIds = currentProjektIds.filter( function(element) { return element !== '' } )
          currentPageUrl.searchParams.set('projekts', currentProjektIds.join(','))
        }
      }

      if (clickedUrl.searchParams.get('geozone_restriction')) {
        newGeoZoneRestriction = clickedUrl.searchParams.get('geozone_restriction');

        if (currentGeoZoneRestriction == newGeoZoneRestriction) {
          currentPageUrl.searchParams.set('geozone_restriction', '')
        } else {
          currentPageUrl.searchParams.set('geozone_restriction', newGeoZoneRestriction)
        }
      }

      if (clickedUrl.searchParams.get('geozones')) {
        newGeoZoneId = clickedUrl.searchParams.get('geozones').split(',')[0];

        if (currentGeoZoneIds.includes(newGeoZoneId)) {
          var index = currentGeoZoneIds.indexOf(newGeoZoneId);
          if (index > -1) {
            currentGeoZoneIds.splice(index, 1);
          }
          currentPageUrl.searchParams.set('geozones', currentGeoZoneIds.join(','))
          currentPageUrl.searchParams.set('geozone_restriction', 'only_geozones')
        } else {
          currentGeoZoneIds.push(newGeoZoneId)
          currentGeoZoneIds = currentGeoZoneIds.filter( function(element) { return element !== '' } )
          currentPageUrl.searchParams.set('geozones', currentGeoZoneIds.join(','))
          currentPageUrl.searchParams.set('geozone_restriction', 'only_geozones')
        }
      }

      if (clickedUrl.searchParams.get('tags')) {
        newTag = clickedUrl.searchParams.get('tags').split(',')[0];

        if (currentTags.includes(newTag)) {
          var index = currentTags.indexOf(newTag);
          if (index > -1) {
            currentTags.splice(index, 1);
          }
          currentPageUrl.searchParams.set('tags', currentTags.join(','))
        } else {
          currentTags.push(newTag)
          currentPageUrl.searchParams.set('tags', currentTags.join(','))
        }
      }


      window.history.pushState('', '', currentPageUrl)
      window.location.href = currentPageUrl.href;

    },


    // Initializer
 
    initialize: function() {
      $("body").on("click", ".js-show-children-projekts", function(event) {
        event.preventDefault();

        if ( event.target.tagName == 'LABEL' ) {
          var $label = $(this)
        } else {
          var $label = $(this).parent()
        }

        App.Projekts.toggleChildProjekts($label);
        App.Projekts.highlightLabel($label);
        return false;
      });

      $("body").on("click", ".js-select-projekt", function() {
        var $label = $(this).parent()

        if ( $label.hasClass('projekt-phase-disabled')) {
          return false;
        }

        var $radioButton = $label.find(":radio").first()
        App.Projekts.highlightLabel($label);

        if ( $radioButton.is(":checked") ) {
          $radioButton.prop( "checked", false);
        } else {
          $radioButton.prop( "checked", true );
        }
      });

      $("body").on("click", ".js-filter-projekt", function() {
        var $checkbox = $(this);
        App.Projekts.formNewFilterProjektsRequest($checkbox);

        var $parentProjekt = $(this).closest('li');

        if ( $parentProjekt.next().prop("tagName")  === 'UL' && $checkbox.is(':checked')  ) {
          var $childrentCheckboxes = $parentProjekt.siblings().find('.js-filter-projekt');

          $childrentCheckboxes.each( function() {
            $(this).prop( "checked", true )
            App.Projekts.formNewFilterProjektsRequest($(this));
          });
        }
      });

      $("body").on("click", ".js-apply-projekts-filter", function(event) {
        event.preventDefault();
        var url = new URL(window.location.href);

        if (url.searchParams.get('page')) {
          url.searchParams.delete('page');
        }

        window.location.href = url;
      });

      $("body").on("click", ".js-reset-projekts-filter", function(event) {
        $('#filter-projekts-all input').each(
          function() {
            $(this).prop('checked', false)
          }
        )

        var url = new URL(window.location.href);
        url.searchParams.delete('projekts')
        window.history.pushState('', '', url)

      });

      $("body").on("click", ".js-projekt-tag-filter-link", function(event) {
        event.preventDefault()
        var clickedLink = this.href
        App.Projekts.modifyFilterParams(clickedLink);
      });


      $("body").on("click", ".js-icon-toggle-child-projekts", function(event) {
        var $label = $(this).parent();
        App.Projekts.toggleChildrenInSidebar($label);
      });

      $("body").on("click", ".js-toggle-edit-projekt-info", function(event) {
        var $row = $(this).closest('tr');
        App.Projekts.toggleChildrenInSidebar($row);

      })

    }
  };
}).call(this);
