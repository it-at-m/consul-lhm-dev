(function() {
  "use strict";
  App.UserResourcesFormComponent = {
    initialize: function() {
      var userResourceForm = document.getElementById("new_proposal");

      if (userResourceForm) {
        return;
      }

      userResourceForm.addEventListener("submit", function(event) {
        // Prevent the userResourceForm from submitting immediately
        event.preventDefault();

        // Get the current content of the CKEditor
        for (var key in CKEDITOR.instances) {
          var editor = CKEDITOR.instances[key];
          var existingPlaceholderElement = editor.document.$.querySelector("p[data-cke-placeholdertext]");

          if (existingPlaceholderElement) {
            editor.setData("");
          }
        }

        userResourceForm.submit();
      });
    },
  };
}).call(this);
