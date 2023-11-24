(function() {
  "use strict";
  App.QuestionWizard = {
    initialize: function() {
      var $questionWizard = $(".js-question-wizard");

      $questionWizard.on("click", ".js-question-wizard-prev", this.navigateToPrevQuestion.bind(this));
      $questionWizard.on("click", ".js-question-wizard-next", this.navigateToNextQuestion.bind(this));
      $questionWizard.on("click", ".js-question-wizard-go-to-start", this.goToStart.bind(this));

      if ($questionWizard.length > 0) {
        this.updateProgress($questionWizard.find(".js-question-wizard-item").get(0));
      }
    },

    currentQuestion: function() {
      return document.querySelector(".js-question-wizard .js-question-wizard-item.-visible");
    },

    getQuestionById: function(id) {
      return document.querySelector(
        ".js-question-wizard [data-question-id='" + id + "']"
      );
    },

    navigateToQuestionById: function(id) {
      var question = this.getQuestionById(id);
      this.navigateToQuestion(question);
    },

    navigateToPrevQuestion: function() {
      var prevQuestion = $(this.currentQuestion()).prevAll(".js-question-wizard-item:not(.-disabled)").get(0);

      this.navigateToQuestion(prevQuestion);
    },

    navigateToNextQuestion: function() {
      var currentQuestion = this.currentQuestion();
      var alreadyAnsweredOption = document.querySelector(
        ".js-question-wizard-item.-visible .js-question-answered"
      );
      var nextQuestion;

      if (alreadyAnsweredOption && alreadyAnsweredOption.dataset.nextQuestionId) {
        nextQuestion = this.getQuestionById(alreadyAnsweredOption.dataset.nextQuestionId);

        var $questionsToMarkAsDisabled =
          $(currentQuestion)
            .nextUntil(
              ".js-question-wizard [data-question-id='" + alreadyAnsweredOption.dataset.nextQuestionId + "']"
            );

        $questionsToMarkAsDisabled.addClass("-disabled");
      } else {
        nextQuestion = currentQuestion.nextElementSibling;
      }

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
        nextQuestion.classList.remove("-disabled");

        // $(".js-question-wizard--progress-current-page").text(nextQuestion.dataset.questionNumber);
        this.updateProgress(nextQuestion);

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
    },

    updateProgress: function(nextQuestion) {
      var totalQuestionsCount = $(".js-question-wizard-item").length;
      var progressbarWidth = $(".js-question-wizard--progress").width();
      var width = progressbarWidth * (nextQuestion.dataset.questionNumber / totalQuestionsCount);
      $(".js-question-wizard .js-question-wizard--progress-bar").css("width", width);
    }
  };
}).call(this);
