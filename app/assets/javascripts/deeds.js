// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

document.addEventListener('turbolinks:load', function() {
  var deedForm = document.querySelector('form#new_deed');

  if (!deedForm) {
    return;
  }

  document.querySelectorAll('form#new_deed .mdc-textfield').forEach(function(textfield) {
    mdc.textfield.MDCTextfield.attachTo(textfield);
  });

  var addNameButton = deedForm.querySelector('.add-name');

  // var thankText = deedForm.querySelector('#thank_text');
  // var remaningTextLength = deedForm.querySelector('#remaining_thank_text_length');
  // var deedUrl = deedForm.querySelector('#deed_url');
  // var submitButton = deedForm.querySelector('input[type=submit]');

    addNameButton.addEventListener('click', showName);
  // thankText.addEventListener('input', validateText);
  // validateText();

  function showName(event) {
    event.preventDefault();
    if (deedForm.querySelectorAll('.name.hidden').length <= 1) {
      deedForm.querySelector('.add-name').parentNode.classList.add('add-name--animating');
    }
    deedForm.querySelector('.name.hidden').classList.add('name-field--animating');
    deedForm.querySelector('.name.hidden').classList.remove('hidden');
    return false;
  }

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
