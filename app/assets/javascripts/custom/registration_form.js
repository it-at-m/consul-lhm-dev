(function() {
  "use strict";
  App.RegistrationForm = {
    initialize: function() {
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
