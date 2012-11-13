//= require active_admin/base
//= require vendor/select2
//= require vendor/redactor
// require jquery.ui.tabs

$(document).ready(function(){
  if($("select.select2").length) {
    $("select.select2").select2();
  }

  $('#entry_body').redactor({
    focus: false,
    buttons: ['bold', 'italic', 'link', 'unorderedlist'],
    lang: 'pl'
  })
});