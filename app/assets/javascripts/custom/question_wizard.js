(function() {
  "use strict";
  App.QuestionWizard = {
    initialize: function() {
      $(".js-question-wizard").on("click", ".js-question-wizard-prev", this.goToPrevQuestion.bind(this));
      $(".js-question-wizard").on("click", ".js-question-wizard-next", this.goToNextQuestion.bind(this));

      // $(".question-wizard-item form").on("ajax:success", this.navigateToQuestionById.bind(this));
    },

    currentQuestion: function() {
      return document.querySelector(".js-question-wizard .js-question-wizard-item.-visible");
    },

    goToPrevQuestion: function() {
      var currentQuestion = this.currentQuestion();
      var prevQuestion = currentQuestion.previousElementSibling;

      this.navigateToQuestion(prevQuestion);
    },

    goToNextQuestion: function() {
      var currentQuestion = this.currentQuestion();
      var nextQuestion = currentQuestion.nextElementSibling;

      this.navigateToQuestion(nextQuestion);
    },

    navigateToQuestionById: function(id) {
      var nextQuestion = document.querySelector(".js-question-wizard [data-question-id='" + id + "']");
      this.navigateToQuestion(nextQuestion);
    },

    navigateToQuestion: function(nextQuestion) {
      if (nextQuestion) {
        this.currentQuestion().classList.remove("-visible");
        nextQuestion.classList.add("-visible");
      }

      var $nextButton = $(".js-question-wizard-next");

      if (nextQuestion.nextElementSibling) {
        $nextButton.css("visibility", "visible");
      } else {
        $nextButton.css("visibility", "hidden");
      }

      var $previousButton = $(".js-question-wizard-prev");

      if (nextQuestion.previousElementSibling) {
        $previousButton.css("visibility", "visible");
      } else {
        $previousButton.css("visibility", "hidden");
      }
    }
  };
}).call(this);
