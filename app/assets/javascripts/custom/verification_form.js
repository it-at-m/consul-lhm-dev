(function() {
  "use strict";
  App.VerificationForm = {
    initialize: function() {
      $("body").on("change", ".js-verification-city-selector", function() {
        $.get("/users/registrations/update_registered_address_street_field.js?form_registered_address_city_id=" + event.target.value);
      });

      $("body").on("change", ".js-verification-street-selector", function() {
        $.get("/users/registrations/update_registered_address_field.js?form_registered_address_street_id=" + event.target.value);
      });

      $("body").on("change", ".js-verification-address-selector", function() {
        if (event.target.value === "0") {
          $("#no-registered-address").css("display", "block");
        } else {
          $("#no-registered-address").css("display", "none");
        }
      });
    }
  };
}).call(this);
