// (function() {
//   "use strict";
//   App.MobileScrollNavigation = {
//     initialized: false,
//
//     initialize: function() {
//       if (this.initialized) {
//         return;
//       }
//
//       if (!this.header()) {
//         return;
//       }
//
//       window.onscroll = this.handleScroll.bind(this);
//
//       // Get the offset position of the header
//       this.initialHeaderOffsetY = this.header().offsetTop;
//       this.initialized = true;
//     },
//
//     header() {
//       return document.querySelector(".js-stiky-header");
//     },
//
//     handleScroll: function() {
//       if (window.pageYOffset > this.initialHeaderOffsetY) {
//         this.header().classList.add("sticky-header");
//       } else if (window.pageXOffset === this.initialHeaderOffsetY) {
//         this.header().classList.remove("sticky-header");
//       }
//     }
//   };
// }).call(this);
