(function() {
  "use strict";
  App.DropdownMenuComponent = {
    initialized: false,

    initialize: function() {
      if (this.initialized) {
        return;
      }

      window.addEventListener("click", function(e) {
        if (e.target.closest(".dropdown-container") === null) {
          this.closeDropdown();
        }
      }.bind(this));

      $(document).on("click", ".js-dropdown-toggle", this.openDropdown.bind(this));
      $(document).on("click", ".js-dropdown-item a", this.selectOption.bind(this));

      this.initialized = true;
    },

    openDropdown: function(e) {
      e.preventDefault();

      var $dropdownElement = $(e.currentTarget.parentElement);

      if ($dropdownElement.hasClass("dropdown-open") === true) {
        $dropdownElement.removeClass("dropdown-open");
      } else {
        this.closeDropdown();
        $dropdownElement.addClass("dropdown-open");
      }
    },

    closeDropdown: function() {
      $(".dropdown-container.dropdown-open").removeClass("dropdown-open");
    },

    selectOption: function(e) {
      this.closeDropdown();
      e.currentTarget.closest(".js-dropdown").querySelector(".dropdown-toggle").innerHTML = e.currentTarget.textContent;
    }
  };
}).call(this);
