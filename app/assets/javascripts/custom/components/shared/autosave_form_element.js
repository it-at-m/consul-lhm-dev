(function() {
  "use strict";
  App.AutosaveFormElement = {
    initialize: function() {
      $(".js-autosave-form input").on("change", this.saveForm);
    },

    saveForm: function(e) {
      var target = e.target;
      $(target.form).trigger("submit.rails");
    }
  };
}).call(this);
