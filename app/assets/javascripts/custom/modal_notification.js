(function() {
  "use strict";
  App.ModalNotification = {
    showModal: function() {
      if ( $('#currentModalNotification').length ) {
        var cookieName = 'modalNotification' + $('#currentModalNotification').data('modalNotificationId')

        if ( App.Cookies.getCookie(cookieName) != 'seen' ) {
          App.Cookies.saveCookie( cookieName, 'seen', 365)
          $('#currentModalNotification').foundation('open');
        }
      }
    },

    initialize: function() {
      App.ModalNotification.showModal();
    }
  };
}).call(this);
