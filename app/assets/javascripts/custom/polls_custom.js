(function() {
  "use strict";
  App.PollsCustom = {

    hideOpenAnswers: function() {
      $('.poll-results-open-answers').each( function() {
        if ( sessionStorage.getItem($(this).attr('id')) !== 'true' ) {
          sessionStorage.setItem( $(this).attr('id'), 'false');
          $(this).removeClass('show-open-answers')
        }
      })

      $('.poll-results-open-answers-list').each( function() {
        var sessionStorageItemId = $(this).closest('.poll-results-open-answers').attr('id')
        if ( sessionStorage.getItem(sessionStorageItemId) !== 'true' ) {
          $(this).hide();
        }
      })
    },

    initialize: function() {
      App.PollsCustom.hideOpenAnswers()

      $("body").on("click", ".js-show-open-answers", function() {
        var $wrapper = $(this).closest('.poll-results-open-answers')
        var $questionList = $(this).siblings('.poll-results-open-answers-list')
        var currentSessionStorageWrapperValue = sessionStorage.getItem($wrapper.attr('id'))

        if ( currentSessionStorageWrapperValue === 'true' ) {
          sessionStorage.setItem( $wrapper.attr('id'), 'false' )
          $wrapper.removeClass('show-open-answers')
          $questionList.hide();
        } else {
          sessionStorage.setItem( $wrapper.attr('id'), 'true' )
          $wrapper.addClass('show-open-answers')
          $questionList.show();
        }

      });
    }
  }
}).call(this);
