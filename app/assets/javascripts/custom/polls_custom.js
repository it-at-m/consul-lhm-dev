(function() {
  "use strict";
  App.PollsCustom = {

    initialize: function() {
      $("body").on("click", ".js-show-open-answers", function() {
        $(this).closest('.poll-results-open-answers').toggleClass('show-open-answers')
      });
    }

  }
}).call(this);
