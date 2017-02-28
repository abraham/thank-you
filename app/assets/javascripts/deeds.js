// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

document.addEventListener('turbolinks:load', function() {
  var deedForm = document.querySelector('form.new_deed') || document.querySelector('form.edit_deed');

  if (!deedForm) {
    return;
  }

  deedForm.querySelectorAll('.mdc-textfield').forEach(function(textfield) {
    mdc.textfield.MDCTextfield.attachTo(textfield);
  });

  var addNameButton = deedForm.querySelector('.add-name');

  var deedText = deedForm.querySelector('#deed_text');
  var namesText = deedForm.querySelectorAll('input#deed_names_');
  var remainingTextLengthDisplay = deedForm.querySelector('#remaining_deed_text_length');
  var submitButton = deedForm.querySelector('input[type=submit]');

  namesText.forEach(function(nameText) {
    nameText.addEventListener('input', validateText);
  });
  addNameButton.addEventListener('click', showName);
  deedText.addEventListener('input', validateText);
  validateText();

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

  function deedTweetText() {
    return 'Thank You ' + toSentence(names()) + ' for ' + deedText.value + ' https://example.com/';
  }

  function validateText() {
    var text = deedTweetText();
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
    return 140 - twttr.txt.getTweetLength(deedTweetText());
  }

  function renderRemainingTextLength(length) {
    remainingTextLengthDisplay.innerText = length;
  }

  function names() {
    var names = [];
    namesText.forEach(function(elem) {
      var name = elem.value.trim();
      if (name) {
        names.push('@' + name)
      }
    });

    return names;
  }

  function toSentence(array) {
    var wordsConnector = ", ";
    var twoWordsConnector = " and ";
    var lastWordConnector = ", and ";
    var sentence;

    switch(array.length) {
      case 0:
        sentence = "";
        break;
      case 1:
        sentence = array[0];
        break;
      case 2:
        sentence = array[0] + twoWordsConnector + array[1];
        break;
      default:
        sentence = array.slice(0, -1).join(wordsConnector) + lastWordConnector + array[array.length - 1];
        break;
    }

    return sentence;
  }
});
