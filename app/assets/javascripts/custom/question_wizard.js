(function() {
  "use strict";
  App.QuestionWizard = {
    initialize: function() {
      $(".js-question-wizard").on("click", ".js-question-wizard-prev", this.goToPrevQuestion.bind(this));
      $(".js-question-wizard").on("click", ".js-question-wizard-next", this.goToNextQuestion.bind(this));
      $(".js-question-wizard").on("click", ".js-question-wizard-go-to-start", this.goToStart.bind(this));
    },

    currentQuestion: function() {
      return document.querySelector(".js-question-wizard .js-question-wizard-item.-visible");
    },

    getQuestionById: function(id) {
      return document.querySelector(
        ".js-question-wizard [data-question-id='" + id + "']"
      );
    },

    goToPrevQuestion: function() {
      var prevButton = document.querySelector(".js-question-wizard-prev");
      var prevQuestion = this.getQuestionById(prevButton.dataset.prevQuestionId);

      this.navigateToQuestion(prevQuestion);
    },

    goToNextQuestion: function() {
      var currentQuestion = this.currentQuestion();
      var alreadyAnsweredOption = document.querySelector(".js-question-answered");
      var nextQuestion;

      if (alreadyAnsweredOption && alreadyAnsweredOption.dataset.nextQuestionId) {
        nextQuestion = this.getQuestionById(alreadyAnsweredOption.dataset.nextQuestionId);
      } else {
        nextQuestion = currentQuestion.nextElementSibling;
      }

      var previousButton = document.querySelector(".js-question-wizard-prev");
      previousButton.dataset.prevQuestionId = this.currentQuestion().dataset.questionId;

      this.navigateToQuestion(nextQuestion);
    },

    firstQuestion: function() {
      return document.querySelector(".js-question-wizard .js-question-wizard-item:first-child");
    },

    goToStart: function() {
      var nextQuestion = this.firstQuestion();

      this.navigateToQuestion(nextQuestion);
    },

    navigateToQuestion: function(nextQuestion) {
      if (nextQuestion) {
        this.currentQuestion().classList.remove("-visible");
        nextQuestion.classList.add("-visible");

        $(".js-question-wizard--progress-current-page").text(nextQuestion.dataset.questionNumber);

        var $nextButton = $(".js-question-wizard-next");

        if (nextQuestion.nextElementSibling) {
          $nextButton.show();
        } else {
          $nextButton.hide();
        }

        var $previousButton = $(".js-question-wizard-prev");
        if (nextQuestion.previousElementSibling) {
          $previousButton.show();
        } else {
          $previousButton.hide();
        }
      }

      if (this.firstQuestion() === nextQuestion) {
        $(".js-question-wizard-go-to-start").hide();
      } else {
        $(".js-question-wizard-go-to-start").show();
      }
    }
  };
}).call(this);
