(function() {
  "use strict";
  App.HTMLEditor = {
    initialize: function() {
      $("textarea.html-area").each(function(index, element) {
        var editorHeight = $(this).hasClass("tall-editor") ? 334 : 334;

        if ($(this).hasClass("extended-u")) {
          CKEDITOR.replace(this.name, { language: $("html").attr("lang"), toolbar: "extended_user", height: editorHeight });
        } else if ($(this).hasClass("extended-a")) {
          CKEDITOR.replace(this.id, { language: $("html").attr("lang"), toolbar: "extended_admin", height: editorHeight });

        } else {
          CKEDITOR.replace(this.name, { language: $("html").attr("lang"), height: editorHeight });
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
