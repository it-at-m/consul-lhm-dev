(function() {
  "use strict";
  App.ProjektQuestionCustom = {
    debounce: function(func, duration, immediate) {
      var timeout;

      return function() {
        var context = this, args = arguments;
        var later = function() {
          timeout = null;
          if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;

        clearTimeout(timeout);
        timeout = setTimeout(later, duration);

        if (callNow) func.apply(context, args);
      };
    },

    loadQuestionSection: function(url) {
      $.get(url)
    },

    submitForm: function(e) {
      var $element = $(e.currentTarget)
      $element.closest('form').trigger('submit.rails')
      var $elementLabel = $element.parent('label')

      $elementLabel.parent().find('label input[type="radio"]').prop('disabled', true)

      $elementLabel.siblings('label').removeClass('is-active')
      $elementLabel.addClass('is-active')
      $(".js-projekt-question-section").addClass("show-loader");
    },

    initialize: function() {
      $("body").on("click", ".js-projekt-question-next", function(e) {
        e.preventDefault()
        e.stopPropagation()
        this.loadQuestionSection(e.currentTarget.href)
      }.bind(this));

      $('body').on('change', '.js-project-question-list form input', this.debounce(this.submitForm.bind(this), 500))
      $('body').on('click', 'js-projekt-question-switch', this.loadQuestionSection.bind(this))
    }
  }
}).call(this);
