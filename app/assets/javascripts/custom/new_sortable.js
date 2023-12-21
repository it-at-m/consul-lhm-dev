(function() {
  "use strict";
  App.NewSortable = {
    initialize: function() {
      $(".js-new-sortable").sortable({
        update: function() {
          var new_order = $(this).sortable("toArray", {
            attribute: "data-record-id"
          });

          $.ajax({
            url: $(".js-new-sortable").data("sort-url"),
            data: {
              ordered_list: new_order
            },
            type: "POST"
          });
        }
      });
    }
  };
}).call(this);
