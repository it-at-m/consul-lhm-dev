(function() {
  "use strict";
  App.CkeEditorPlaceholder = {
    initialize: function() {
      var form = document.querySelector(".js-rich-text-form");

      if (!form) {
        return;
      }

      // Add a submit event listener to the form
      form.addEventListener("submit", function(event) {
        // Prevent the form from submitting immediately
        event.preventDefault();

        // Get the current content of the CKEditor
        for (var key in CKEDITOR.instances) {
          var editor = CKEDITOR.instances[key];
          var existingPlaceholderElement = editor.document.$.querySelector("p[data-cke-placeholdertext]");

          if (existingPlaceholderElement) {
            editor.setData("");
          }
        }

        form.submit();
      });
    }
  };
}).call(this);
