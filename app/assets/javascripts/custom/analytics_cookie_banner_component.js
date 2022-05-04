(function() {
  "use strict";
  App.AnalyticsCookieBannerCustom = {
    analyticsCookieName: 'statistic_cookies_enabled',
    analyticsCookieJustChangedCookieName: 'statistic_cookies_setting_just_changed',

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
      App.Cookies.saveCookie(this.analyticsCookieName, 'true', 360)
    },

    analyticsCookieJustChanged: function(value) {
      App.Cookies.saveCookie(this.analyticsCookieJustChangedCookieName, 'true', 360)
    },

    setStatisticCookie: function(value) {
      App.Cookies.saveCookie(this.analyticsCookieName, value.toString(), 360)
    },

    statisticCookiesCheckbox: function() {
      return document.querySelector('.js-accept-analytics-cookies')
    },

    saveSettings: function() {
      var analyticsCookiesAccepted = this.statisticCookiesCheckbox().checked

      this.setStatisticCookie(analyticsCookiesAccepted)
      this.analyticsCookieJustChanged()

      this.close()
    },

    acceptAll: function() {
      this.statisticCookiesCheckbox().checked = true
      this.analyticsCookieJustChanged()
      App.Cookies.saveCookie(this.analyticsCookieName, 'true', 360)

      this.close()
    },

    setStatisticCookieFromUserProfileSetting: function() {
      var userStatisticCheckbox = document.querySelector('.js-user-setting-enable-statistic-cookies')

      if (userStatisticCheckbox) {
        this.setStatisticCookie(userStatisticCheckbox.checked)
      }
    },

    handleOpenSettingsAgain: function(e) {
      e.preventDefault()
      e.stopPropagation()

      this.open()
    },

    setupEventListeners: function() {
      $('.js-analytics-cookies-accept-all-button').on('click', this.acceptAll.bind(this))
      $('.js-analytics-cookies-save-settings-button').on('click', this.saveSettings.bind(this))
      $('.js-user-settings-form').on('submit', this.setStatisticCookieFromUserProfileSetting.bind(this))
      $('.js-statistic-cookies-settings').on('click', this.handleOpenSettingsAgain.bind(this))
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
      // Clarify if this cheek is needed
      // if (this.analyticsCookieSettingForUserIsSet()) return
      if (window.location.pathname === '/account') return

      this.open()
    }
  };
}).call(this);
