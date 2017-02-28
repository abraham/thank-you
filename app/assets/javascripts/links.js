// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

document.addEventListener('turbolinks:load', function() {
  var linkForm = document.querySelector('form.new_link');

  if (!linkForm) {
    return;
  }

  linkForm.querySelectorAll('.mdc-textfield').forEach(function(textfield) {
    mdc.textfield.MDCTextfield.attachTo(textfield);
  });
});
