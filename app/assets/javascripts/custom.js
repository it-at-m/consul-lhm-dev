//= require custom/textarea_autoexpand
//= require custom/mjAccordion.js
//= require turbolinks

function initializeMjAccordion() {
  "use strict";
  $(".mj_accordion").mjAccordion();
}

function initComponents() {
  "use strict";

  initializeMjAccordion();
  App.CollapseTextComponent.initialize();
}

$(function() {
  "use strict";

  $(document).ready(function() {
    initComponents();
  });

  $(document).on("turbolinks:load", function() {
    initComponents();
  });
});
