(function() {
  "use strict";
  App.HTMLEditor = {
    initialize: function() {
      this.enableCustomCkeditorStyles();

      $("textarea.html-area").each(function(_, element) {
        App.HTMLEditor.enableCKeditorFor(element);
      });
    },

    enableCKeditorFor: function(element) {
      if ($(document.body).hasClass('custom-new-design')) {
        var hasNewDesign = true;
      }

      if ($(element).hasClass("extended-u")) {
        var replaceBy = element.name;
        var toolbar = "extended_user";
      } else if ($(element).hasClass("extended-a")) {
        var replaceBy = element.id;
        var toolbar = "extended_admin";
      } else {
        var replaceBy = element.name;
      }

      if (hasNewDesign) {
        var height = 320;
      }
      else {
        var height = $(element).hasClass("tall-editor") ? 334 : 334;
      }

      var language = $("html").attr("lang");

      CKEDITOR.replace(replaceBy, {
        language: language,
        toolbar: toolbar,
        height: height,
        placeholdertext: element.dataset.placeholder
      });
    },

    enableCustomCkeditorStyles: function() {
      if ($(document.body).hasClass('custom-new-design')) {
        CKEDITOR.addCss(".cke_editable{font-size: 16px; line-height: 1.3; }");
        CKEDITOR.addCss("p[data-cke-placeholdertext] { font-size: 16px; line-height: 1.1; } ");
      }
    },

    destroy: function() {
      for (var name in CKEDITOR.instances) {
        CKEDITOR.instances[name].destroy();
      }
    }
  };
}).call(this);

