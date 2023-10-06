(function() {
  "use strict";
  App.DropzoneUploadComponent = {
    initialize: function() {
      // $(".js-dropzone").each(function(_, component) {
      //   App.DropzoneUploadComponent.initForOneComponent(component);
      // });

      App.DropzoneUploadComponent.initEvents();
    },

    initEvents: function() {
      $(".js-dropzone-image-upload--file-attach-area").each(function(_index, fileAttachArea) {
        fileAttachArea.addEventListener("click", App.DropzoneUploadComponent.fileAttachAreaClick);
      });
      $(".js-dropzone-image-upload-custom-edit-button").each(function(_index, fileAttachArea) {
        fileAttachArea.addEventListener("click", App.DropzoneUploadComponent.fileAttachAreaClick);
      });

      $(".js-dropzone-image-upload--input").each(function(_index, fileAttachArea) {
        fileAttachArea.addEventListener("change", App.DropzoneUploadComponent.handleFileChange);
      });
    },

    fileAttachAreaClick: function(e) {
      var uploadInput =
        e.currentTarget
          .closest(".js-dropzone-image-upload")
          .querySelector(".js-dropzone-image-upload--input")
          .click();
    },

    handleFileChange: function(e) {
      var file = e.currentTarget.files[0];

      if (file) {
        var fileReader = new FileReader();
        var uploadElement = e.currentTarget.closest(".js-dropzone-image-upload");
        var preview = uploadElement.querySelector(".js-dropzone-image-upload--preview");
        var previewWrapper = uploadElement.querySelector(".js-dropzone-image-upload--preview-wrapper");

        var fileSize = (file.size / 1024 / 1024).toFixed(2);

        if (fileSize > 5) {
          alert("File size must be less than 5 MB.");
          e.currentTarget.value = "";
          return false;
        }

        fileReader.onload = function(event) {
          preview.setAttribute("src", event.target.result);
          previewWrapper.classList.add("-visible");
        };

        fileReader.readAsDataURL(file);

        var shouldSubmitForm = uploadElement.dataset.submitForm;

        if (shouldSubmitForm) {
          var form = uploadElement.closest("form");
          form.requestSubmit();
        }
        e.currentTarget.disabled = true;
      }
    },
  };
}).call(this);
