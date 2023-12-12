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

      $("body").on("change", ".js-registration-address-selector", function() {
        if (event.target.value === "0") {
          $("#no-registered-address").css("display", "block");
        } else {
          $("#no-registered-address").css("display", "none");
        }
      });

      $("body").on("change", ".js-registered-address-choose", function() {
        var selectedCityId = $("#form_registered_address_city_id").val();
        var selectedStreetId = $("#form_registered_address_street_id").val();

        if ( selectedCityId === "0") {
          $("#user-regular-address-fields").css("display", "block");
        } else {
          $("#user-regular-address-fields").css("display", "none");
        }

        $.get("/registered_addresses/find", {
          selected_city_id: selectedCityId,
          selected_street_id: selectedStreetId
        });
      })
    }
  };
}).call(this);
