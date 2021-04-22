//= require custom/textarea_autoexpand
//= require custom/mjAccordion.js
//= require turbolinks


var mj;
mj = function() {
  $(".mj_accordion").mjAccordion()
};

$(function() {

  $(document).ready(mj);
  $(document).on('turbolinks:load', mj);
});
