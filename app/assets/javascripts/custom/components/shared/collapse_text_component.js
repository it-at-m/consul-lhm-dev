(function() {
  "use strict";
  App.CollapseTextComponent = {
    initialized: false,
    initialize: function() {
      if (!this.initialized) {
        $(document).on("click", ".js-collapse-show-more-button", this.toggleCollapse.bind(this));
      }

      this.initialized = true;

      this.enableHoverButtons();
    },
    enableHoverButtons: function() {
      var collapseTextInnerElements = document.querySelectorAll(".js-collapse-text-widget-inner");

      if (collapseTextInnerElements) {
        collapseTextInnerElements.forEach(function(element) {
          this.enableShowMoreButtonIfOverflowing(element);
        }.bind(this));
      }
    },
    enableShowMoreButtonIfOverflowing: function(element) {
      if (this.isOverflowing(element)) {
        element.parentElement.querySelector(".js-collapse-show-more-button").style.display = "block";
      } else {
        $(element).addClass('-expanded')
      }
    },
    toggleCollapse: function(e) {
      var showMoreButton = e.target;

      var collapseTextElement =
        showMoreButton
          .closest(".js-collapse-text-widget")
          .querySelector(".js-collapse-text-widget-inner");

      collapseTextElement.classList.toggle("-expanded");

      var newButtonText;

      if (collapseTextElement.classList.contains("-expanded")) {
        newButtonText = showMoreButton.dataset.showLessText;
      } else {
        newButtonText = showMoreButton.dataset.showMoreText;
      }

      showMoreButton.innerHTML = newButtonText;
    },
    isOverflowing: function(element) {
      return (
        element.clientHeight < element.scrollHeight
      );
    }
  };
}).call(this);
