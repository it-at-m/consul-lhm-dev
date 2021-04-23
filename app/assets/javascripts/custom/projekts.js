(function() {
  "use strict";
  App.Projekts = {

    // Functions for selectors in form

    toggleChildProjekts: function($label) {
      var projektId = $label.data()['projektId']
      var dataParentIdentifierString = "[data-parent=\"" + projektId + "\"]"
      var $childrenProjektsGroup = $( dataParentIdentifierString )

      if ( $childrenProjektsGroup.is(":hidden") ) {
        App.Projekts.resetSelectedChildren($label);
        $childrenProjektsGroup.show()
      } else {
        App.Projekts.resetSelectedChildren($label);
      }
    },

    resetSelectedChildren: function($label) {
      var $currentProjektGroup = $label.parent();
      var $currentColumn = $label.parent().parent()

      $currentProjektGroup.find('label').each(function() {
        App.Projekts.restyleHidingElements($(this));
      });

      $currentColumn.nextAll().each(function() {
        $(this).find(".projekt-group").each( function() {
          $(this).find('label').each(function() {
            App.Projekts.restyleHidingElements($(this));
          })
          $(this).hide();
        })
      })
    },

    restyleHidingElements: function($label) {
      $label.css('background', '#fff')
      $label.css('color', '#C6C6C6');
      $label.find('.checkmark').css('border-color', '#C6C6C6')

      if ( $label.find('input').first().is(':checked') ) {
        App.Projekts.showCheckmark($label);
      };
    },

    styleSelectedProjekt: function($label) {
      $label.css('background', '#ECF2FB');
      $label.css('color', '#06408E');
      $label.find('.checkmark').css('border', '1.5px solid #06408E')

      if ( $label.find('input').first().is(':checked') ) {
        $label.find('.checkmark').css('background', '#06408E')
        $label.find('.checkmark-before').show()
      };
    },

    hideCheckmark: function($label) {
      $label.find('.checkmark-before').hide()
      $label.find('.checkmark').css('background', 'inherit')
      $label.find('.checkmark').css('border', '1.5px solid #C6C6C6')
      $label.css('color', '#C6C6C6');
    },

    showCheckmark: function($label) {
      $label.find('.checkmark-before').show()
      $label.find('.checkmark').css('background', '#06408E')
      $label.find('.checkmark').css('border', '1.5px solid #06408E')
      $label.css('color', '#06408E');
    },

    removeCheckboxChip: function(projektId) {
      var projektChipId = "#projekt-chip-" + projektId
      var $projektChip = $(projektChipId).parent();
      $projektChip.remove();
    },

    addCheckboxChip: function($label) {
      var projektId = 'projekt-chip-' + $label.data()['projektId']
      var projektName = $label.text()

      var chipToAdd = '<div class="projekt-chip">'

      chipToAdd += projektName
      chipToAdd += '<span id=' + projektId + ' class="js-deselect-projekt close"></span>'
      chipToAdd += '</div>'


      $('#projekt-chips').append(chipToAdd)
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
      var currentTags;

      if (currentPageUrl.searchParams.get('projekts')) {
        currentProjektIds = currentPageUrl.searchParams.get('projekts').split(',');
      } else {
        currentProjektIds = [];
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
      var newTag;

      if (clickedUrl.searchParams.get('projekts')) {
        newProjektId = clickedUrl.searchParams.get('projekts').split(',')[0];

        if (currentProjektIds.includes(newProjektId)) {
          var index = currentProjektIds.indexOf(newProjektId);
          if (index > -1) {
            currentProjektIds.splice(index, 1);
          }
          currentPageUrl.searchParams.set('projekts', currentProjektIds.join(','))
          window.history.pushState('', '', currentPageUrl)
          window.location.href = currentPageUrl;
        } else {
          currentProjektIds.push(newProjektId)
          currentProjektIds = currentProjektIds.filter( function(element) { return element !== '' } )
          currentPageUrl.searchParams.set('projekts', currentProjektIds.join(','))
          window.history.pushState('', '', currentPageUrl)
          window.location.href = currentPageUrl.href;
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
          window.history.pushState('', '', currentPageUrl)
          window.location.href = currentPageUrl;
        } else {
          currentTags.push(newTag)
          currentPageUrl.searchParams.set('tags', currentTags.join(','))
          window.history.pushState('', '', currentPageUrl)
          window.location.href = currentPageUrl.href;
        }
      }

    },


    // Initializer
 
    initialize: function() {
      $("body").on("click", ".js-show-children-projekts", function(event) {
        event.preventDefault();
        if ( event.target.classList.contains('js-show-children-projekts') ) {
          var $label = $(this)
          App.Projekts.toggleChildProjekts($label);
          App.Projekts.styleSelectedProjekt($label);
          return false;
        }
      });

      $("body").on("click", ".js-select-projekt", function() {
        var $label = $(this).parent()
        var $checkbox = $label.find("input").first()
        var projektId = $(this).parent().data()['projektId']

        if ( $checkbox.is(":checked") ) {
          $checkbox.prop( "checked", false);
          App.Projekts.hideCheckmark($label);
          App.Projekts.removeCheckboxChip(projektId)
        } else {
          $checkbox.prop( "checked", true );
          App.Projekts.showCheckmark($label);
          App.Projekts.addCheckboxChip($label)
        }
      });

      $("body").on("click", ".js-deselect-projekt", function() {
        var projektId = this.id.split('-').pop()
        var correspoindLabelIdentifierString = "[data-projekt-id=\"" + projektId + "\"]"
        var $correspondingLabel = $(correspoindLabelIdentifierString)
        var $checkbox = $correspondingLabel.find('input')

        $checkbox.prop( "checked", false);
        App.Projekts.hideCheckmark($correspondingLabel);
        App.Projekts.removeCheckboxChip(projektId);
      });

      $("body").on("click", ".js-filter-projekt", function() {
        var $checkbox = $(this);
        App.Projekts.formNewFilterProjektsRequest($checkbox);
        var $parentProjekt = $(this).closest('li');

        if ( $parentProjekt.next().prop("tagName")  === 'UL' && $checkbox.is(':checked')  ) {
          var $childrentCheckboxes = $parentProjekt.next().find('.js-filter-projekt');

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

      $("body").on("click", ".js-projekt-tag-filter-link", function(event) {
        event.preventDefault()
        var clickedLink = this.href
        App.Projekts.modifyFilterParams(clickedLink);
      });


      $("body").on("click", ".js-icon-toggle-child-projekts", function(event) {
        var $label = $(this).parent();
        App.Projekts.toggleChildrenInSidebar($label);
      });

    }
  };
}).call(this);
