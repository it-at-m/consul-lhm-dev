(function() {
  "use strict";
  App.LivesteamLivequestion = {
    initialize: function() {
      this.startLivequtionLoad();
    },

    livequestionElement: function() {
      return document.querySelector(".js-livestream-livequestion");
    },

    clearInterval: function() {
      if (this.questionLoadInterval) {
        clearInterval(this.questionLoadInterval);
      }
    },

    startLivequtionLoad: function() {
      var livequestion = this.livequestionElement();

      this.clearInterval();

      if (livequestion) {
        this.questionLoadInterval = setInterval(
          function() {
            this.loadNewQuestions();
          }.bind(this),
          10000
        );
      }
    },

    loadNewQuestions: function() {
      var livequestion = this.livequestionElement();

      if (!livequestion) {
        this.clearInterval();
        return;
      }

      if (livequestion.dataset.url) {
        $.ajax({
          url: livequestion.dataset.url,
          method: "POST"
        });
      }
    }
  };
}).call(this);
