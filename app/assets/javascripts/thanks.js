// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//= require twitter-text/build/twitter-text

document.addEventListener('turbolinks:load', function() {
  var thankForm = document.querySelector('form#new_thank');
  if (!thankForm) {
    return;
  }

  document.querySelectorAll('form#new_thank .mdc-textfield').forEach(function(textfield) {
    mdc.textfield.MDCTextfield.attachTo(textfield);
  });

  var thankText = thankForm.querySelector('#thank_text');
  var remainingTextLengthDisplay = thankForm.querySelector('#remaining_thank_text_length');
  var deedUrl = thankForm.querySelector('#deed_url');
  var submitButton = thankForm.querySelector('input[type=submit]');

  thankText.addEventListener('input', validateText);
  validateText();

  function validTweet(text) {
    return twttr.txt.isInvalidTweet(text) === false;
  }

  function thankTweetText() {
    return thankText.value + ' ' + deedUrl.innerText;
  }

  function validateText() {
    var text = thankTweetText();
    if (validTweet(text)) {
      submitButton.disabled = false;
      remainingTextLengthDisplay.parentNode.classList.remove('error-text');
    } else {
      submitButton.disabled = true;
      remainingTextLengthDisplay.parentNode.classList.add('error-text');
    }
    renderRemainingTextLength(remainingTextLength());
  }

  function remainingTextLength() {
    return 140 - twttr.txt.getTweetLength(thankTweetText());
  }

  function renderRemainingTextLength(length) {
    remainingTextLengthDisplay.innerText = length;
  }
});
