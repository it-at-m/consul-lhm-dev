(function() {
  "use strict";
  App.GDPRNotice = {
    hideGDPRNotice: function() {
      $("body .js-gdpr-notice").each(function() {
        if ( App.Cookies.getCookie('gdpr_notice_accept') ) {
          $(this).addClass('hide')
        }
      })
    },

    accept: function() {
      event.preventDefault();
      App.Cookies.saveCookie('gdpr_notice_accept', true, 180)
      App.GDPRNotice.hideGDPRNotice();
    },

    reject: function() {
      event.preventDefault();
      App.Cookies.saveCookie('gdpr_notice_accept', false, 180)
      App.GDPRNotice.hideGDPRNotice();
    },

    initialize: function() {
      $("body").on("click", ".js-accept-gdpr-notice", function() {
        App.GDPRNotice.accept();
      });

      $("body").on("click", ".js-reject-gdpr-notice", function() {
        App.GDPRNotice.reject();
      });

      App.GDPRNotice.hideGDPRNotice();
    }
  };
}).call(this);
