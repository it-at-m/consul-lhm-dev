(function() {
  "use strict";
  App.SDGCustom = {

    updateSDGFilterGoals: function() {
      var url = new URL(window.location.href);
      var clickedSDGCode = $(event.target).parent().attr('data-code');
      var currentSDGTarget = "";


      if (url.searchParams.get('sdg_targets')) {
        currentSDGTarget = url.searchParams.get('sdg_targets').split(',')[0]
      }

      if (url.searchParams.get('sdg_goals')) {
        var currentSDGCodes = url.searchParams.get('sdg_goals').split(',');
      } else {
        var currentSDGCodes = [];
      };

      if ( currentSDGCodes.includes(clickedSDGCode)) {
        currentSDGCodes = currentSDGCodes.filter( function(element) { return element !== clickedSDGCode } )
      } else {
        currentSDGCodes.push(clickedSDGCode)
      };

      if ( currentSDGCodes.length > 0 ) {
				url.searchParams.set('sdg_goals', currentSDGCodes.join(','))
      } else {
        url.searchParams.delete('sdg_goals')
      };

      if ( !currentSDGCodes.includes(currentSDGTarget.split('.')[0]) ) {
        url.searchParams.delete('sdg_targets')
      }

      url.searchParams.delete('search')

      window.history.pushState('', '', url);
      window.location.href = url.href;
    },

    updateSDGFilterTargets: function(selectedValue, source = '') {
      var url = new URL(window.location.href);
      var currentSDGTargetCodes = url.searchParams.get('sdg_targets') || [];

      if (currentSDGTargetCodes.includes(selectedValue)) {
        currentSDGTargetCodes = [];
      } else {
        currentSDGTargetCodes = [selectedValue];
      }

      url.searchParams.set('sdg_targets', currentSDGTargetCodes.join(','))

      if ( currentSDGTargetCodes.length > 0 ) {
        url.searchParams.set('sdg_goals', currentSDGTargetCodes[0].split('.')[0])
      }

      if ( currentSDGTargetCodes.length == 0 ) {
        url.searchParams.delete('sdg_targets')
      };

      url.searchParams.delete('search')

      window.history.pushState('', '', url);
      window.location.href = url.href;
    },

    initialize: function() {
      $("body").on("click", ".js-sdg-custom-goal-filter", function(event) {
        event.preventDefault();
        App.SDGCustom.updateSDGFilterGoals();
      });

      $("body").on("change", ".js-sdg-custom-target-filter-dropdown", function(event) {
        var selectedValue = event.target.value;
        App.SDGCustom.updateSDGFilterTargets(selectedValue);
      });
    }
  };
}).call(this);
