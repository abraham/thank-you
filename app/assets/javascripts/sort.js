document.addEventListener('turbolinks:load', function() {
  var menu = document.querySelector('.sort .mdc-simple-menu');
  var button = document.querySelector('.sort .menu')
  if (button && menu) {
    var menu = new mdc.menu.MDCSimpleMenu(menu);
    button.addEventListener('click', function() { menu.open = !menu.open });
  }
});
