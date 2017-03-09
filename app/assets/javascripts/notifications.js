document.addEventListener('turbolinks:load', function() {
  var notificationsUI = document.querySelector('.notifications');
  var currentToken;
  var browserToken;

  if (notificationsUI) {
    currentToken = formToken();
    if (supported()) {
      console.log('Notifications supported');
      enableSwitch(globalSwitch());
      getBrowserToken().then(checkSubscription);
      globalSwitch().addEventListener('click', toggleGlobal);
      topicSwitches().forEach(function(topic) {
        topic.addEventListener('click', toggleSwitch);
      });
    } else {
      console.log('Notifications not supported');
      showUnsupported();
    }
  }

  function globalSwitch() {
    return notificationsUI.querySelector('input#notifications');
  }

  function setGlobalSwitch(value) {
    setSwitch(globalSwitch(), value);
    if (value) {
      enableTopicSwitches();
    }
  }

  function enableSwitch(el) {
    el.removeAttribute('disabled');
    el.parentNode.classList.remove('mdc-switch--disabled');
  }

  function disableSwitch(el) {
    el.setAttribute('disabled', true);
    el.parentNode.classList.add('mdc-switch--disabled');
  }

  function checkSubscription() {
    if (browserToken) {
      setGlobalSwitch(true);
    }
    if (browserToken && browserToken !== currentToken) {
      return createSubscription().then(renderSubscription);
    }
  }

  function toggleGlobal(event) {
    console.log('toggleGlobal', event.target.checked, event.target.id, browserToken);
    var enabled = event.target.checked;
    if (enabled) {
      requestPermission()
        .then(getBrowserToken)
        .then(createSubscription)
        .then(function(subscription) {
          console.log('created', subscription);
          enableTopicSwitches();
          renderSubscription(subscription);
          snackbar.show({ message: 'Notifications enabled' });
        });
    } else {
      messaging.deleteToken(browserToken)
        .then(deleteSubscription)
        .then(function(subscription) {
          console.log('deleted', subscription);
          disableTopicSwitches();
          snackbar.show({ message: 'Notifications disabled' });
        });
    }
  }

  function csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  }

  function formToken() {
    return notificationsUI.querySelector('#subscription_token').getAttribute('value');
  }

  function toggleSwitch(event) {
    console.log('event', event.target.checked, event.target.id, currentToken);
    var enabled = event.target.checked;
    var topic = event.target.id;
    if (enabled) {
      patchSubscription('add', topic)
        .then(function(result) {
          console.log('added', result);
          snackbar.show({ message: 'Notification enabled' });
        });
    } else {
      patchSubscription('remove', topic)
        .then(function(result) {
          console.log('removed', result);
          snackbar.show({ message: 'Notification disabled' });
        });
    }
  }

  function topicSwitches() {
    return notificationsUI.querySelectorAll('input.topic');
  }

  function topicSwitch(id) {
    return notificationsUI.querySelector('input#' + id);

  }

  function clearTopicSwitches() {
    topicSwitches().forEach(function(topic) {
      setSwitch(topic, false);
    });
  }

  function enableTopicSwitches() {
    topicSwitches().forEach(function(topic) {
      enableSwitch(topic);
    });
  }

  function disableTopicSwitches() {
    clearTopicSwitches();
    topicSwitches().forEach(function(topic) {
      disableSwitch(topic);
    });
  }

  function renderSubscription(subscription) {
    console.log('subscription', subscription);
    clearTopicSwitches();
    subscription.topics.forEach(function(topic) {
      setSwitch(topicSwitch(topic), true);
    });
  }

  function setSwitch(el, value) {
    el.checked = value;
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

  function createSubscription() {
    var data = {
      subscription: {
        token: browserToken
      }
    }

    return fetch('/subscriptions', {
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

  function patchSubscription(change, topic) {
    var data = {
      subscription: {
        changes: [{
          change: change,
          topic: topic
        }]
      }
    }

    return fetch('/subscriptions', {
      method: 'PATCH',
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

  function deleteSubscription() {
    return fetch('/subscriptions', {
      method: 'DELETE',
      headers: {
        'Content-type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      },
      credentials: 'same-origin'
    })
    .then(function(response) {
      browserToken = undefined;
      currentToken = undefined;
      return response.json();
    });
  }

  function notificationsEnabled() {
    notificationsUI.querySelector('input#deeds').checked = true;
  }

  function requestPermission() {
    return messaging.requestPermission()
      .then(function() {
        console.log('Notification permission granted.');
      })
      .catch(function(err) {
        console.log('Unable to get permission to notify.', err);
      });
  }

  function getBrowserToken() {
    return messaging.getToken()
      .then(function(token) {
        browserToken = token;
        if (token) {
          console.log('Browser token', token);
          // setGlobalSwitch(true);
        } else {
          console.log('No Instance ID token available. Request permission to generate one.');
        }
      })
      .catch(function(err) {
        console.log('An error occurred while retrieving token. ', err);
      });
  }
});
