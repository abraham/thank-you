// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//= require twitter-text/twitter-text

document.addEventListener('turbolinks:load', function() {
  var thankForm = document.querySelector('#new_thank');
  if (!thankForm) {
    return;
  }

  var thankText = thankForm.querySelector('#thank_text');
  var remaningTextLength = thankForm.querySelector('#remaining_thank_text_length');
  var thankUrl = thankForm.querySelector('#thank_url');
  var submitButton = thankForm.querySelector('input[type=submit]');

  thankText.addEventListener('input', validateText);
  validateText();

  function validTweet(text) {
    return twttr.txt.isInvalidTweet(text) === false;
  }

  function thankTweetText() {
    return thankText.value + ' ' + thankUrl.innerText;
  }

  function validateText() {
    var text = thankTweetText();
    if (validTweet(text)) {
      submitButton.disabled = false;
    } else {
      submitButton.disabled = true;
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
