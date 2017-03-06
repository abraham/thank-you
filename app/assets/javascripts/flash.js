var snackbar;
document.addEventListener('turbolinks:load', function() {
  var snackbarEl = document.querySelector('.mdc-snackbar');
  if (!snackbarEl) {
    return;
  }

  snackbar = mdc.snackbar.MDCSnackbar.attachTo(snackbarEl);

  document.querySelectorAll('.snackbar-message').forEach(function(el) {
    snackbar.show({ message: el.getAttribute('data-message'), multiline: isMultiline(el) });
  });

  function isMultiline(el) {
    var value = el.getAttribute('data-multiline');
    return value === 'true' || value === true;
  }
});
