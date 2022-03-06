(function() {
  "use strict";
  App.AnalyticsCookieBannerCustom = {
    analyticsCookieName: 'analytics_cookies_accepted',

    open: function() {
      $('#model-question').foundation('open')
    },

    close: function() {
      $('#model-question').foundation('close')
    },

    confirm: function() {
      var analyticsCookiesAccepted = document.querySelector('.js-accept-analytics-cookies').checked

      App.Cookies.saveCookie(this.analyticsCookieName, analyticsCookiesAccepted.toString(), 360)

      this.close()
      this.enableMatomoIfEnabled()
    },

    reject: function() {
      App.Cookies.saveCookie(this.analyticsCookieName, 'false', 360)

      this.close()
    },

    setupEventListeners: function() {
      $('.js-analytics-cookies-accept-button').on('click', this.confirm.bind(this))
      $('.js-analytics-cookies-reject-button').on('click', this.reject.bind(this))
    },

    isCookiePreferenceAlreadyStored: function() {
      var analyticsCookie = App.Cookies.getCookie(this.analyticsCookieName)

      return (analyticsCookie === 'true' || analyticsCookie === 'false')
    },

    analyticsCookie: function() {
      return App.Cookies.getCookie(this.analyticsCookieName)
    },

    isAnalyticsEnabled: function() {
      var analyticsCookie = App.Cookies.getCookie(this.analyticsCookieName)
      return (analyticsCookie === 'true')
    },

    hideGDPRNotice: function() {
      $('.js-gdpr-notice').hide()
    },

    enableMatomo: function() {
      var _paq = window._paq = window._paq || [];
      /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
      _paq.push(['trackPageView']);
      _paq.push(['enableLinkTracking']);

      (function() {
        var u="https://www75.muenchen.de/";
        var previousPageUrl = null;

        addEventListener('turbolinks:load', function(event) {
          if (previousPageUrl) {
            _paq.push(['setReferrerUrl', previousPageUrl]);
            _paq.push(['setCustomUrl', window.location.href]);
            _paq.push(['setDocumentTitle', document.title]);
            _paq.push(['trackPageView']);
          }

          previousPageUrl = window.location.href;
        });

        _paq.push(['setTrackerUrl', u+'matomo.php']);
        _paq.push(['setSiteId', '19']);
        var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
        g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
      })();
    },

    enableMatomoIfEnabled: function() {
      if (this.isAnalyticsEnabled()) {
        this.enableMatomo()
      }
    },

    initialize: function() {
      this.hideGDPRNotice()
      this.enableMatomoIfEnabled()

      if (this.isCookiePreferenceAlreadyStored()) return

      this.open()
      this.setupEventListeners()
    }
  };
}).call(this);
