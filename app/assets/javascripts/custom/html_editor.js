(function() {
  "use strict";
  App.HTMLEditor = {
    initialize: function() {
      $("textarea.html-area").each(function() {
        if ($(this).hasClass("extended-u")) {
          CKEDITOR.replace(this.name, { language: $("html").attr("lang"), toolbar: "extended_user", height: 500 });

        } else if ($(this).hasClass("extended-a")) {
          CKEDITOR.replace(this.name, { language: $("html").attr("lang"), toolbar: "extended_admin", height: 500 });

        } else {
          CKEDITOR.replace(this.name, { language: $("html").attr("lang") });
        }
      });
    },
    destroy: function() {
      for (var name in CKEDITOR.instances) {
        CKEDITOR.instances[name].destroy();
      }
    }
  };
}).call(this);
