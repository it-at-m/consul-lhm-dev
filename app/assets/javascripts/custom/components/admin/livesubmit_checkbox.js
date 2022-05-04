(function() {
  "use strict";
  App.LivesubmitCheckboxCustom = {
    initialize: function() {
      $('.js-livesubmit-checkbox').on('ajax:complete', function(e) {
        var target = e.target
        var valueElement = target.querySelector('.js-livesubmit-checkbox-value')
        var button = target.querySelector('button[type="submit"]')

        setTimeout(function() {
          if (valueElement.value === 'true') {
            valueElement.value = 'false'
            button.ariaPressed = 'true'
            button.innerHTML = target.dataset.enabledText
          }
          else {
            valueElement.value = 'true'
            button.ariaPressed = 'false'
            button.innerHTML = target.dataset.disabledText
          }
        }, 10)
      })
    }
  }
}).call(this);
