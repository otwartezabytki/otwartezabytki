//= require jquery.ui.tabs
//= require vendor/select2
//= require vendor/redactor

$(document).ready(function(){
  if($("select.select2").length) {
    $("select.select2").select2();
  }

  // In one line for easy removal using sed
  $('#entry_body').redactor({ focus: false, buttons: ['bold', 'italic', 'link', 'unorderedlist'], lang: 'pl' })
});
