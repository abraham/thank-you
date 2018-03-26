// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require material-components-web/dist/material-components-web
//= require rails-ujs
//= require turbolinks
//= require_tree .

console.log('Hello World from The Asset Pipeline');

Raven.config('https://5e69813822924122ae73456b7057c338@sentry.io/135599').install();

document.addEventListener('turbolinks:load', function() {
  mdc.autoInit();

  document.querySelectorAll('.mdc-button').forEach(function(btn) {
    mdc.ripple.MDCRipple.attachTo(btn);
  });
});

var config = {
  apiKey: document.querySelector('meta[name=firebase-api-key]').getAttribute('content'),
  messagingSenderId: document.querySelector('meta[name=firebase-messaging-sender-id]').getAttribute('content')
};
firebase.initializeApp(config);
var messaging = firebase.messaging();
