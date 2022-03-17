(function() {
  App.RadioButtonFilter = {
    initialize: function() {
      $(".js-radio-button-filter").on("change", function(e) {
        var params = new URLSearchParams(window.location.search)

        var filterName = e.currentTarget.name
        var filterValue = e.currentTarget.value

        params.set(filterName, filterValue)

        Turbolinks.visit(window.location.pathname + '?' + params.toString())
      });
    }
  }
}).call(this);
