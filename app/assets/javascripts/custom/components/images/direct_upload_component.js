(function() {
  "use strict";
  App.DirectUploadComponent = {
    initialize: function() {
      $(".js-direct-image-upload").each(function(_, component) {
        App.DirectUploadComponent.initForOneComponent(component);
      });

      App.DirectUploadComponent.initEvents();
    },

    initEvents: function() {
      $(".js-direct-image-upload--file-attach-area").each(function(_index, fileAttachArea) {
        fileAttachArea.addEventListener("click", App.DirectUploadComponent.fileAttachAreaClick);
      });
      $(".js-direct-image-upload-custom-edit-button").each(function(_index, fileAttachArea) {
        fileAttachArea.addEventListener("click", App.DirectUploadComponent.fileAttachAreaClick);
      });

      App.DirectUploadComponent.initializeRemoveCachedImageLinks();
    },

    fileAttachAreaClick: function(e) {
      e.currentTarget
        .closest(".js-direct-image-upload")
        .querySelector(".js-direct-image-upload--input")
        .click();
    },

    initForOneComponent: function(component) {
      var input = component.querySelector(".js-direct-image-upload--input");
      var inputData = this.buildData([], input);

      $(input).fileupload({
        paramName: "attachment",
        formData: null,
        add: function(e, data) {
          var upload_data = App.DirectUploadComponent.buildData(data, e.target);

          App.DirectUploadComponent.clearProgressBar(upload_data);
          App.DirectUploadComponent.setProgressBar(upload_data, "uploading");

          upload_data.submit();
        },

        change: function(e, data) {
          data.files.forEach(function(file) {
            App.DirectUploadComponent.setFilename(inputData, file.name);
          });
        },

        fail: function(e, data) {
          $(data.cachedAttachmentField).val("");

          App.DirectUploadComponent.clearFilename(data);
          App.DirectUploadComponent.setProgressBar(data, "errors");
          App.DirectUploadComponent.clearInputErrors(data);
          App.DirectUploadComponent.setInputErrors(data);
          App.DirectUploadComponent.clearPreview(data);

          $(data.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove();
          $(data.addAttachmentLabel).addClass("error");
        },
        done: function(e, data) {
          var $dataWrapper = data.wrapper;
          var shouldSubmitForm = $dataWrapper.data("submit-form") === true;

          if (shouldSubmitForm) {
            var $idElemnt = $(".js-direct-image-upload--id");

            $idElemnt.val("");
            $(data.cachedAttachmentField).val("");
          }

          $(data.cachedAttachmentField).val(data.result.cached_attachment);

          App.DirectUploadComponent.setTitleFromFile(data, data.result.filename);
          App.DirectUploadComponent.clearProgressBar(data);
          App.DirectUploadComponent.setFilename(data, data.result.filename);
          App.DirectUploadComponent.clearInputErrors(data);
          App.DirectUploadComponent.setPreview(data);
          var destroyAttachmentLink = $(data.result.destroy_link);
          $(data.destroyAttachmentLinkContainer).html(destroyAttachmentLink);

          if (shouldSubmitForm) {
            var form = $dataWrapper.closest("form")[0];
            form.requestSubmit();
          }
        },

        progress: function(e, data) {
          var progress;
          progress = parseInt(data.loaded / data.total * 100, 10);
          $(data.progressBar).find(".direct-image-upload--loading-bar").css("width", progress + "%");
        }
      });
    },

    buildData: function(data, input) {
      var wrapper;
      wrapper = $(input).closest(".js-direct-image-upload");
      var $wrapper = $(wrapper);

      data.wrapper = wrapper;
      data.progressBar = $wrapper.find(".direct-image-upload--progress-bar-wrapper");
      data.preview = $wrapper.find(".image-preview");
      data.errorContainer = $wrapper.find(".js-attachment-errors");
      data.fileNameContainer = $wrapper.find(".js-file-name");
      data.destroyAttachmentLinkContainer = $wrapper.find(".action-remove");
      data.addAttachmentLabel = $wrapper.find(".action-add label");
      data.cachedAttachmentField = $wrapper.find("input[name$='[cached_attachment]']");
      data.titleField = $wrapper.find("input[name$='[title]']");
      $wrapper.find(".direct-image-upload--progress-bar-wrapper").css("display", "block");

      return data;
    },

    clearFilename: function(data) {
      $(data.fileNameContainer).text("");
      $(data.fileNameContainer).attr("title", "");
    },
    clearInputErrors: function(data) {
      $(data.errorContainer).find("small.error").remove();
    },

    clearProgressBar: function(data) {
      $(data.progressBar).find(".direct-image-upload--loading-bar").removeClass("complete errors uploading").css("width", "0px");
      data.progressBar.css("display", "none");
    },

    clearPreview: function(data) {
      $(data.wrapper).find(".image-preview").remove();
    },

    setFilename: function(data, file_name) {
      $(data.fileNameContainer).text(file_name);
      $(data.fileNameContainer).attr("title", file_name);
    },

    setProgressBar: function(data, klass) {
      data.progressBar.css("display", "block");
      $(data.progressBar).find(".direct-image-upload--loading-bar").addClass(klass);
    },

    setTitleFromFile: function(data, title) {
      if ($(data.titleField).val() === "") {
        $(data.titleField).val(title);
      }
    },

    setInputErrors: function(data) {
      var errors;
      errors = "<small class='error'>" + data.jqXHR.responseJSON.errors + "</small>";
      $(data.errorContainer).append(errors);
    },

    setPreview: function(data) {
      var image_preview;
      image_preview = "<div class='image-preview'><figure><img src='" + data.result.attachment_url + '?' + Date.now() + "' class='cached-image'></figure></div>";
      var $dataWrapper = $(data.wrapper);

      if ($(data.preview).length > 0) {
        $(data.preview).replaceWith(image_preview);
      } else {
        var $actionsArea = $dataWrapper.find(".js-direct-image-upload--attachment-actions");

        $(image_preview).insertBefore($actionsArea);
        data.preview = $dataWrapper.find(".image-preview");
      }

      $dataWrapper.find(".js-direct-image-upload--preview-area").addClass("-preview-set");
    },

    initializeRemoveCachedImageLinks: function() {
      $(".js-direct-image-upload").on("click", ".remove-cached-attachment", function(event) {
        event.preventDefault();
        // $("#new_image_link").removeClass("hide");
        var $mainElement = $(this).closest(".js-direct-image-upload");

        $mainElement.find(".js-direct-image-upload--preview-area").removeClass("-preview-set");
        $mainElement.find(".js-direct-image-upload--cached-attachment").val("");
      });
    },
  };
}).call(this);
