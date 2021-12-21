(function() {
  "use strict";
  App.DeficiencyReports = {

    updateSelectedDeficiencyCategoriesParamFromTag: function() {
      event.preventDefault();
      var url = new URL(window.location.href);
      var selectedCategoriesIds;
      var clickedCategoryId;

      if (url.searchParams.get('dr_categories')) {
        selectedCategoriesIds = url.searchParams.get('dr_categories').split(',');
      } else {
        selectedCategoriesIds = [];
      }

      clickedCategoryId = event.target.dataset['categoryId'];

      var index = selectedCategoriesIds.indexOf(clickedCategoryId);
      if (index > -1) {
        selectedCategoriesIds.splice(index, 1);
      } else {
        selectedCategoriesIds.push( event.target.dataset['categoryId'] );
      }

      if ( selectedCategoriesIds.length > 0 ) {
        url.searchParams.set('dr_categories', selectedCategoriesIds.join(','))
      } else {
        url.searchParams.delete('dr_categories')
      }

      window.history.pushState('', '', url)
      window.location.href = url;

    },

    updateDeficiencyReportsParams: function($checkbox) {
      var url = new URL(window.location.href);
      var selectedCategoriesIds;
      var uniqueCategoriesIds;

      if (url.searchParams.get('dr_categories')) {
        selectedCategoriesIds = url.searchParams.get('dr_categories').split(',');
      } else {
        selectedCategoriesIds = [];
      }

      if ( $checkbox.is(':checked') ) {
        selectedCategoriesIds.push($checkbox.val());
      } else {
        var index = selectedCategoriesIds.indexOf($checkbox.val());
        if (index > -1) {
          selectedCategoriesIds.splice(index, 1);
        }
      }

      var uniqueCategoriesIds = selectedCategoriesIds.filter( function(v, i, a) { return a.indexOf(v) === i } );

      if ( uniqueCategoriesIds.length > 0 ) {
        url.searchParams.set('dr_categories', uniqueCategoriesIds.join(','))
      } else {
        url.searchParams.delete('dr_categories')
      }

      window.history.pushState('', '', url)
    },

    resetCategoryFilter: function() {
      $('#deficiency-report-categories-sidebar-filter input').each(
        function() {
          $(this).prop('checked', false)
        }
      )

      var url = new URL(window.location.href);
      url.searchParams.delete('dr_categories');
      window.history.pushState('', '', url);
      window.location.href = url;
    },

    updateLabelStyle: function($li) {
      $li.siblings('li').removeClass('label-selected')
      $li.addClass('label-selected')
    },

    updateSelectedDeficiencyStatusParam: function($label) {
      var url = new URL(window.location.href);
      var selection = $('input[name="status"]:checked').val();

      if ( selection == 0 ) {
        url.searchParams.delete('dr_status')
      } else {
        url.searchParams.set('dr_status', selection)
      }

      url.searchParams.delete('search')
      url.searchParams.delete('page')
      window.history.pushState('', '', url)
      window.location.href = url;
    },

    updateSelectedFilter: function($label, filter_name, default_value) {
      var url = new URL(window.location.href);
      var selection = $('input[name=' + filter_name + ']:checked').val();

      if ( selection == default_value ) {
        url.searchParams.delete(filter_name)
      } else {
        url.searchParams.set(filter_name, selection)
      }

      url.searchParams.delete('search')
      url.searchParams.delete('page')
      window.history.pushState('', '', url)
      window.location.href = url;
    },

    initialize: function() {
      $("body").on("click", ".js-filter-dr-category", function() {
				var $checkbox = $(this)
        App.DeficiencyReports.updateDeficiencyReportsParams($checkbox)
      });


      $("body").on("click", ".js-reset-dr-category-filter", function() {
        App.DeficiencyReports.resetCategoryFilter()
      });


      $("body").on("click", ".js-filter-by-deficiency-report-status", function() {
        var $label = $(this).closest('label');
        App.DeficiencyReports.updateLabelStyle($label.closest('li'));
        App.DeficiencyReports.updateSelectedDeficiencyStatusParam($label);
      });

      $("body").on("click", ".js-filter-by-deficiency-report-officer", function() {
        var $label = $(this).closest('label');
        App.DeficiencyReports.updateLabelStyle($label.closest('li'));
        App.DeficiencyReports.updateSelectedFilter($label, 'dr_officer', 'all');
      });

      $("body").on("click", ".js-filter-by-deficiency-report-approval-status", function() {
        var $label = $(this).closest('label');
        App.DeficiencyReports.updateLabelStyle($label.closest('li'));
        App.DeficiencyReports.updateSelectedFilter($label, 'approval_status', 'all');
      });

      $("body").on("click", ".js-update-dr-categories", function() {
        App.DeficiencyReports.updateSelectedDeficiencyCategoriesParamFromTag();
      });
    }

  };
}).call(this);
