//= require active_admin/base
//= require vendor/select2
//= require vendor/redactor

$(document).ready(function(){
  $("select.select2").select2();
  $('#entry_body').redactor({
    focus: false,
    buttons: ['bold', 'italic', 'link', 'unorderedlist'],
    lang: 'pl'
  })
});