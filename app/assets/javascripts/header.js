document.addEventListener('turbolinks:load', function() {
  var menuEl = document.querySelector('.mdc-simple-menu');
  var menuIconEl = document.querySelector('header .menu')
  if (menuIconEl && menuEl) {
    var menu = new mdc.menu.MDCSimpleMenu(menuEl);
    menuIconEl.addEventListener('click', function() { menu.open = !menu.open });
  }
});
