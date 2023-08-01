(function() {
  "use strict";

  App.CustomJS = {
    initialize: function() {
      App.DropdownMenuComponent.initialize();
      App.ResourcesListComponent.initialize();
      App.StikyHeader.initialize();
    }
  };
}).call(this);
