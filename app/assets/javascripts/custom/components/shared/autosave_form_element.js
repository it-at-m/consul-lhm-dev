(function() {
  "use strict";
  App.AutosubmitFormElement = {
    initialize: function() {
      $(".js-autosubmit-form input").on("change", this.saveForm);
    },

    saveForm: function(e) {
      var target = e.target;
      $(target.form).trigger("submit.rails");
    }
  };
}).call(this);
