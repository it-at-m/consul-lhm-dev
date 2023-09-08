(function() {
  "use strict";
  App.TextSearchFormComponent = {
    initialize: function() {
      $(document).on("click", ".js-text-search-form-reset-button", this.resetForm.bind(this));
      // $(".js-text-search-form").on("submit", this.enableTurbolinksSubmit.bind(this));
    },

    // enableTurbolinksSubmit: function(e) {
    //   e.preventDefault();
    //   var form = e.currentTarget;
    //
    //   Turbolinks.visit(form.action + "?" + new URLSearchParams(new FormData(form)));
    // },

    resetForm: function(e) {
      var $parentForm = $(e.currentTarget).closest("form");
      var $searchText = $parentForm.find("#search_text");

      $searchText.val("").prop("disabled", true);
      $parentForm.submit();
    }
  };
}).call(this);
