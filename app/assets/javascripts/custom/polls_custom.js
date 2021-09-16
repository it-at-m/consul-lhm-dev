(function() {
  "use strict";
  App.PollsCustom = {

    showOpenAnswers: function() {
      $('.poll-results-open-answers').each( function() {
        if ( sessionStorage.getItem($(this).attr('id')) !== 'true' ) {
          $(this).addClass('hide-open-answers')
        } else {
          $(this).addClass('rotate-toggle-arrow')
        }
      })
    },

    initialize: function() {
      App.PollsCustom.showOpenAnswers()

      $("body").on("click", ".js-show-open-answers", function() {
        var $wrapper = $(this).closest('.poll-results-open-answers')
        var $questionList = $(this).siblings('.poll-results-open-answers-list')
        var currentSessionStorageWrapperValue = sessionStorage.getItem($wrapper.attr('id'))

        if ( currentSessionStorageWrapperValue === 'true' ) {
          sessionStorage.setItem( $wrapper.attr('id'), 'false' );
          $wrapper.removeClass('rotate-toggle-arrow')
          $questionList.hide('fast');
        } else {
          sessionStorage.setItem( $wrapper.attr('id'), 'true' )
          $wrapper.addClass('rotate-toggle-arrow')
          $questionList.show('fast');
        }

      });
    }
  }
}).call(this);
