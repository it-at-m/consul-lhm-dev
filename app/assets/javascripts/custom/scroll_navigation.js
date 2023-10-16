(function() {
  "use strict";
  App.CustomTabs = {
    initialize: function() {
      $(".js-scroll-link").on("click", function(event) {
        event.preventDefault();
        var dataset = event.currentTarget.dataset;
        var anchorId = dataset.anchorId;
        var elemenetToScroll = document.getElementById(anchorId);
        window.scrollTo(0, elemenetToScroll.offsetTop - 140);
      });
    }
  };
}).call(this);
