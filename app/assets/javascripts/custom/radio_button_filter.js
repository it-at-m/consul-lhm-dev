(function() {
  "use strict";

  App.RadioButtonFilter = {
    initialize: function() {
      $(".js-radio-button-filter").on("change", function(e) {
        var params = new URLSearchParams(window.location.search);

        var radioButton = e.currentTarget;
        var filterName = radioButton.name;
        var filterValue = radioButton.value;
        var anchor = radioButton.dataset.anchor;

        params.set(filterName, filterValue);

        var url = window.location.pathname + "?" + params.toString();

        if (anchor) {
          url = url + "#" + anchor;
        }

        Turbolinks.visit(url);
      });
    }
  };
}).call(this);
