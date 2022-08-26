(function() {
  "use strict";
  App.LivesteamLivequestion = {
    initialize: function() {
      if (this.livequestionElement()) {
        this.startLivequtionLoad();
      }
    },

    livequestionElement: function() {
      return document.querySelector(".js-livestream-livequestion");
    },

    startLivequtionLoad: function() {
      if (this.questionLoadInterval) {
        clearInterval(this.questionLoadInterval);
      }

      var livequestion = this.livequestionElement();

      if (livequestion) {
        this.questionLoadInterval = setInterval(
          function() {
            this.loadNewQuestions();
          }.bind(this),
          20000
        );
      }
    },

    loadNewQuestions: function() {
      var livequestion = this.livequestionElement();

      $.ajax({
        url: livequestion.dataset.url,
        method: "POST"
      });
    }
  };
}).call(this);
