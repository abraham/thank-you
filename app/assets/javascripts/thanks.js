// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//= require twitter-text/twitter-text

document.addEventListener('turbolinks:load', function() {
  var thankForm = document.querySelector('#new_thank');
  if (!thankForm) {
    return;
  }

  mdc.textfield.MDCTextfield.attachTo(document.querySelector('.mdc-textfield'));
  var thankText = thankForm.querySelector('#thank_text');
  var remaningTextLength = thankForm.querySelector('#remaining_thank_text_length');
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
      remaningTextLength.parentNode.classList.remove('error-text');
    } else {
      submitButton.disabled = true;
      remaningTextLength.parentNode.classList.add('error-text');
    }
    renderRemainingTextLength(remainingTextLength());
  }

  function remainingTextLength() {
    return 140 - twttr.txt.getTweetLength(thankTweetText());
  }

  function renderRemainingTextLength(length) {
    remaningTextLength.innerText = length;
  }
});
