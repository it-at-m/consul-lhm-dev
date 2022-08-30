(function() {
  "use strict";
  App.LivesteamLivequestion = {
    initialize: function() {
      this.startLivequtionLoad();

      $(document)
        .on("click", ".js-comments-liveupdate-wrapper form.new_comment input[type='submit']", function(e) {
          e.preventDefault();
          e.stopPropagation();

          var form = e.target.form;

          this.loadNewQuestions(function() {
            form.requestSubmit();
          });
        }.bind(this));
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

    loadNewQuestions: function(callback) {
      var livequestion = this.livequestionElement();

      if (!livequestion) {
        this.clearInterval();
        return;
      }

      var url = new URL(location.origin + livequestion.dataset.url);

      var commentsLiveupdateWrapper = document.querySelector(".js-comments-liveupdate-wrapper");

      if (commentsLiveupdateWrapper) {
        var lastCommentId = document.querySelector(".js-comments-liveupdate-wrapper").dataset.lastCommentId;

        if (lastCommentId) {
          url.searchParams.set("last_comment_id", lastCommentId);
        }
      }

      // Workaround for url hadning
      url = url.toString().replace("amp%3B", "");
      url = url.toString().replace("amp;", "").replace("%", "");

      if (livequestion.dataset.url) {
        $.ajax({
          url: url,
          method: "POST"
        }).then(function() {
          if (callback) {
            callback();
          }
        });
      }
    }
  };
}).call(this);
