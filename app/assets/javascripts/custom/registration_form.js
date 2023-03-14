(function() {
  "use strict";
  App.RegistrationForm = {
    initialize: function() {
      $("body").on("change", ".js-registration-city-selector", function() {
        $.get("/users/registrations/update_registered_address_street_field.js?form_registered_address_city_id=" + event.target.value);
      });

      $("body").on("change", ".js-registration-street-selector", function() {
        $.get("/users/registrations/update_registered_address_field.js?form_registered_address_street_id=" + event.target.value);
      });
    }
  };
}).call(this);
