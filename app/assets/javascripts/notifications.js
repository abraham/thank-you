document.addEventListener('turbolinks:load', function() {
  var currentToken;
  var notificationsUI = document.querySelector('.notifications');

  if (notificationsUI) {
    if (supported()) {
      console.log('Notifications supported');
      enableSwitch();
      getToken();
      notificationsUI.querySelector('input#deeds').addEventListener('click', onSwitchChange);
    } else {
      console.log('Notifications not supported');
      showUnsupported();
    }
  }

  function csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  }

  function onSwitchChange(event) {
    console.log('event', event.target.checked, event.target.id, currentToken);
    var enabled = event.target.checked;
    var topic = event.target.id;
    if (currentToken) {
      if (enabled) {
        // TODO: Flashes
        createSubscription(topic)
          .then(function(result) {
            console.log('added', result);
          });
      } else {
        deleteSubscription(topic)
          .then(function(result) {
            console.log('removed', result);
          });
      }
    } else {
      requestPermission();
    }
  }

  function renderSubscriptions(topics) {
    console.log('topics', topics);
    Object.keys(topics).forEach(function(topic) {
      checkSwitch(topic);
    });
  }

  function checkSwitch(id) {
    notificationsUI.querySelector('input#' + id).checked = true;
  }

  function enableSwitch() {
    notificationsUI.querySelector('input#deeds').removeAttribute('disabled');
    notificationsUI.querySelector('.mdc-switch--disabled').classList.remove('mdc-switch--disabled');
  }

  function showUnsupported() {
    notificationsUI.querySelector('.not-supported').classList.remove('hidden');
  }

  function supported() {
    return 'serviceWorker' in navigator && 'PushManager' in window;
  }

  function getSubscriptions() {
    return fetch('subscriptions?subscription[token]=' + currentToken)
      .then(function(response) {
      return response.json();
    });
  }

  function createSubscription(topic) {
    var data = {
      subscription: {
        token: currentToken,
        topic: topic
      }
    }
    return fetch('subscriptions', {
      method: 'POST',
      body: JSON.stringify(data),
      headers: {
        'Content-type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      },
      credentials: 'same-origin'
    })
      .then(function(response) {
      return response.json();
    });
  }

  function deleteSubscription(topic) {
    var data = {
      subscription: {
        token: currentToken,
        topic: topic
      }
    }
    return fetch('subscriptions', {
      method: 'DELETE',
      body: JSON.stringify(data),
      headers: {
        'Content-type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      },
      credentials: 'same-origin'
    })
      .then(function(response) {
      return response.json();
    });
  }

  function notificationsEnabled() {
    notificationsUI.querySelector('input#deeds').checked = true;
  }

  function requestPermission() {
    messaging.requestPermission()
      .then(function() {
        console.log('Notification permission granted.');
        getToken();
      })
      .catch(function(err) {
        console.log('Unable to get permission to notify.', err);
      });
  }

  function getToken() {
    messaging.getToken()
      .then(function(token) {
        currentToken = token
        if (currentToken) {
          console.log('Current token', currentToken);
          getSubscriptions().then(renderSubscriptions);
        } else {
          console.log('No Instance ID token available. Request permission to generate one.');
        }
      })
      .catch(function(err) {
        console.log('An error occurred while retrieving token. ', err);
      });
  }
});
