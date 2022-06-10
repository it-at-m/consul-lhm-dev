(function() {
  "use strict";
  App.Projekts = {

    // Functions for selectors in sidebar

    toggleChildrenInSidebar: function($label) {
      $label.attr('aria-expanded', function (i, attr) {
        return attr == 'true' ? 'false' : 'true'
      });

      $label.children('.toggle-arrow').attr('aria-expanded', $label.attr('aria-expanded'))
      App.Projekts.updateToggledProjektsList($label);

      this.drawProjektFilterTreeLines()
    },

    updateToggledProjektsList: function($label) {
      var resourceName = App.Projekts.selectedProjektIdsKeyName();
			var toggledProjektIds;

      if ( window.localStorage.getItem(resourceName) ) {
				toggledProjektIds = App.Projekts.removeDuplicateValuesFromArray( window.localStorage.getItem(resourceName).split(',') );
      } else {
        toggledProjektIds = [];
      }

      var labelToggleState = $label.children('.toggle-arrow').attr('aria-expanded')

      if ( labelToggleState === 'true' ) {
        toggledProjektIds.push( $label.data('projekt-id') );
      } else {
        var projektIdToRemove = $label.data('projekt-id').toString();
        toggledProjektIds = App.Projekts.removeElementFromArray(toggledProjektIds, projektIdToRemove );
      }

      window.localStorage.setItem(resourceName, toggledProjektIds)
    },

    removeDuplicateValuesFromArray: function(arr) {
      return arr.filter(function(elem, pos, arr) {
        return arr.indexOf(elem) == pos;
      });
    },

    removeElementFromArray: function(arr, el) {
			var index = arr.indexOf(el);
			if (index !== -1) {
				arr.splice(index, 1);
			}
      return arr;
    },

    // Functions for filtering by combination of projects, categories, and user tags

    modifyFilterParams: function(clickedLink) {
      var currentPageUrl = new URL(window.location.href);
      var currentProjektIds;
      var currentGeoZoneRestriction;
      var currentRestrictedGeoZoneIds;
      var currentGeoZoneAffiliation;
      var currentAffiliatedGeoZoneIds;
      var currentTags;

      if (!currentPageUrl.pathname.includes('projekts')) {
        currentPageUrl.pathname = '/projekts'
      }

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

      if (currentPageUrl.searchParams.get('restricted_geozones')) {
        currentRestrictedGeoZoneIds = currentPageUrl.searchParams.get('restricted_geozones').split(',');
      } else {
        currentRestrictedGeoZoneIds = [];
      }

      if (currentPageUrl.searchParams.get('geozone_affiliation')) {
        currentGeoZoneAffiliation = currentPageUrl.searchParams.get('geozone_affiliation');
      } else {
        currentGeoZoneAffiliation = '';
      }

      if (currentPageUrl.searchParams.get('affiliated_geozones')) {
        currentAffiliatedGeoZoneIds = currentPageUrl.searchParams.get('affiliated_geozones').split(',');
      } else {
        currentAffiliatedGeoZoneIds = [];
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
      var newRestrictedGeoZoneId;
      var newGeoZoneAffiliation;
      var newAffiliatedGeoZoneId;
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

      if (clickedUrl.searchParams.get('restricted_geozones')) {
        newRestrictedGeoZoneId = clickedUrl.searchParams.get('restricted_geozones').split(',')[0];

        if (currentRestrictedGeoZoneIds.includes(newRestrictedGeoZoneId)) {
          var index = currentRestrictedGeoZoneIds.indexOf(newRestrictedGeoZoneId);
          if (index > -1) {
            currentRestrictedGeoZoneIds.splice(index, 1);
          }
          currentPageUrl.searchParams.set('restricted_geozones', currentRestrictedGeoZoneIds.join(','))
          currentPageUrl.searchParams.set('geozone_restriction', 'only_geozones')
        } else {
          currentRestrictedGeoZoneIds.push(newRestrictedGeoZoneId)
          currentRestrictedGeoZoneIds = currentRestrictedGeoZoneIds.filter( function(element) { return element !== '' } )
          currentPageUrl.searchParams.set('restricted_geozones', currentRestrictedGeoZoneIds.join(','))
          currentPageUrl.searchParams.set('geozone_restriction', 'only_geozones')
        }
      }

      if (clickedUrl.searchParams.get('geozone_affiliation')) {
        newGeoZoneAffiliation = clickedUrl.searchParams.get('geozone_affiliation');

        if (currentGeoZoneAffiliation == newGeoZoneAffiliation) {
          currentPageUrl.searchParams.set('geozone_affiliation', '')
        } else {
          currentPageUrl.searchParams.set('geozone_affiliation', newGeoZoneAffiliation)
        }
      }
      if (clickedUrl.searchParams.get('affiliated_geozones')) {
        newAffiliatedGeoZoneId = clickedUrl.searchParams.get('affiliated_geozones').split(',')[0];

        if (currentAffiliatedGeoZoneIds.includes(newAffiliatedGeoZoneId)) {
          var index = currentAffiliatedGeoZoneIds.indexOf(newAffiliatedGeoZoneId);
          if (index > -1) {
            currentAffiliatedGeoZoneIds.splice(index, 1);
          }
          currentPageUrl.searchParams.set('affiliated_geozones', currentAffiliatedGeoZoneIds.join(','))
          currentPageUrl.searchParams.set('geozone_affiliation', 'only_geozones')
        } else {
          currentAffiliatedGeoZoneIds.push(newAffiliatedGeoZoneId)
          currentAffiliatedGeoZoneIds = currentAffiliatedGeoZoneIds.filter( function(element) { return element !== '' } )
          currentPageUrl.searchParams.set('affiliated_geozones', currentAffiliatedGeoZoneIds.join(','))
          currentPageUrl.searchParams.set('geozone_affiliation', 'only_geozones')
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

      currentPageUrl.searchParams.delete('search')

      window.history.pushState('', '', currentPageUrl)
      window.location.href = currentPageUrl.href;

    },

    selectedProjektIdsKeyName: function() {
      if ( document.getElementById('filter-projekts-all') ) {
        return document.getElementById('filter-projekts-all').dataset.resourcesName + 'ProjektFilterToggleIds'
      } else {
        return ''
      }
    },

    toggleDefaultProjekts: function() {

      if ( document.getElementById('filter-projekts-all') ) {
        var selectedProjektIdsKeyName = App.Projekts.selectedProjektIdsKeyName();
        var projektIdsToToggle = document.getElementById('filter-projekts-all').dataset.projektsToToggle;
      } else {
        return;
      }

      if ( !window.localStorage.getItem(selectedProjektIdsKeyName) ) {
        window.localStorage.setItem(selectedProjektIdsKeyName, projektIdsToToggle);
      }
    },

    toggleProjektsInSidebarFilter: function() {
      var resourceName = App.Projekts.selectedProjektIdsKeyName();

      var currentUrl = new URL(window.location.href);

      if (currentUrl.searchParams.get('projekts') && currentUrl.searchParams.get('projekts').split(',').length == 1 ) {
        var filteredProjektId = currentUrl.searchParams.get('projekts').split(',')[0];
      }

      $('#filter-projekts-all').find('li').each( function() {
        var projektId = $(this).children('label').children('input').val()

        if ( filteredProjektId && $(this).siblings('ul').find('li[data-projekt-id=' + filteredProjektId + ']').length ) {
          $(this).attr('aria-expanded', 'true')
          $(this).children('.toggle-arrow').attr('aria-expanded', $(this).attr('aria-expanded'))

        } else if ( !filteredProjektId && window.localStorage.getItem(resourceName) && window.localStorage.getItem(resourceName).split(',').includes(projektId) ) {
          $(this).attr('aria-expanded', 'true')
          $(this).children('.toggle-arrow').attr('aria-expanded', $(this).attr('aria-expanded'))
        }
      });

      this.drawProjektFilterTreeLines()
    },

    drawProjektFilterTreeLines: function() {
      var projektTree = document.querySelector('#filter-projekts-all')

      if (projektTree) {
        var $ulElements = $('#filter-projekts-all ul')

        $ulElements.each(function(index, element) {
          var nestedUl = element.querySelector(':scope > ul:last-child')

          if (nestedUl) {
            var elementPosition = element.getBoundingClientRect()
            var netstedUlPosition = nestedUl.getBoundingClientRect()
            var nestedUlLi = nestedUl.querySelector('.mark')

            var lineHeight = (Math.round(netstedUlPosition.top - elementPosition.top) - Math.round(nestedUlLi.offsetHeight / 2) - 2)

            var $lineElement = $(element).children('li').first().children('.projekt-tree-ul-vertical-line')
            // var lineElement = element.querySelector('li:first-child > .projekt-tree-ul-vertical-line')

            $lineElement.css('height', lineHeight + 'px')
          }
        })
      }
    },

    initialize: function() {
      $("body").on("click", ".js-filter-projekt", function() {
        var $checkbox = $(this);
        var $parentProjekt = $(this).closest('li');

        if ( $parentProjekt.next().prop("tagName")  === 'UL') {
          var $childrentCheckboxes = $parentProjekt.siblings().find('.js-filter-projekt');

          if ( $checkbox.is(':checked') ) {
            $childrentCheckboxes.each( function() {
              $(this).prop( "checked", true )
            });
          } else {
            $childrentCheckboxes.each( function() {
              $(this).prop( "checked", false)
            });
          }
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
      });

      $("body").on("click", ".js-reset-projekt-filter-toggle-status", function(event) {
        var resourceName = $(this).data('resources') + 'ProjektFilterToggleIds';
        var projektIds = $(this).data('projekts')
        window.localStorage.setItem(resourceName, projektIds);
      });

      App.Projekts.toggleProjektsInSidebarFilter();

      $("body").on("click", ".js-quick-projekt-update", function(event) {
        event.preventDefault();
        $(this).closest('tr').find('form').submit()
      });

      this.drawProjektFilterTreeLines()
    }
  };
}).call(this);
