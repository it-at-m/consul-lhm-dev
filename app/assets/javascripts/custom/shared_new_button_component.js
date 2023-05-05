(function() {
  "use strict";

  App.SharedNewButtonComponent = {
    not_allowed: function() {
      $("body").on("click", ".new-resource-button", function(event) {
        var notAllowedMessage = $(event.target).next(".new-resource-not-allowed-message");

        if (notAllowedMessage.length > 0) {
          event.preventDefault();
          $(event.target).hide();
          notAllowedMessage.show().focus();
        }
      });
    },
    initialize: function() {
      App.SharedNewButtonComponent.not_allowed();
    }
  };
}).call(this);
