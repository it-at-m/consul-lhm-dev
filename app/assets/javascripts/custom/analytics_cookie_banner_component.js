(function() {
  "use strict";
  App.AnalyticsCookieBannerCustom = {
    analyticsCookieName: 'statistic_cookies_enabled',

    element: function() {
      return $('#statistic-cookie-modal')
    },

    userSetting: function() {
      return $('.js-user-setting-enable-statistic-cookies')
    },

    open: function() {
      this.element().foundation('open')
    },

    close: function() {
      this.element().foundation('close')
    },

    enableStatisticCookie: function() {
      App.Cookies.saveCookie(this.analyticsCookieName, true, 360)
    },

    setStatisticCookie: function(value) {
      App.Cookies.saveCookie(this.analyticsCookieName, value.toString(), 360)
    },

    confirm: function() {
      var analyticsCookiesAccepted = document.querySelector('.js-accept-analytics-cookies').checked

      this.setStatisticCookie(analyticsCookiesAccepted)

      this.close()
      this.enableMatomoIfAllowed()
    },

    reject: function() {
      App.Cookies.saveCookie(this.analyticsCookieName, 'false', 360)

      this.close()
    },

    setupEventListeners: function() {
      $('.js-analytics-cookies-accept-button').on('click', this.confirm.bind(this))
      $('.js-analytics-cookies-reject-button').on('click', this.reject.bind(this))

      $('.js-user-settings-form').on('submit', function() {
        var userStatisticCheckbox = document.querySelector('.js-user-setting-enable-statistic-cookies')

        console.log(userStatisticCheckbox)
        if (userStatisticCheckbox) {
          this.setStatisticCookie(userStatisticCheckbox.checked)
        }
      }.bind(this))
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

    enableMatomoIfAllowed: function() {
      var analyticsCookieEnabledAsUserSetting = (this.analyticsCookieSettingForUserIsSet() && this.analyticsCookieSettingForUserEnabled())

      if (analyticsCookieEnabledAsUserSetting || this.isAnalyticsEnabled()) {
        this.enableMatomo()
      }
    },

    analyticsUserSettingEnabled: function() {
      return this.element().attr('data-statistic-cookie-enabled')
    },

    analyticsCookieSettingForUserIsSet: function() {
      return (this.analyticsUserSettingEnabled() === 'true' || this.analyticsUserSettingEnabled() === 'false')
    },

    analyticsCookieSettingForUserEnabled: function() {
      return (this.analyticsUserSettingEnabled() === 'true')
    },

    initialize: function() {
      this.hideGDPRNotice()
      this.enableMatomoIfAllowed()

      this.setupEventListeners()

      if (this.isCookiePreferenceAlreadyStored()) return
      if (this.analyticsCookieSettingForUserIsSet()) return
      if (window.location.pathname === '/account') return

      this.open()
    }
  };
}).call(this);
