(function($) {
  /*
    Handle collapsible details cookies and interactivity
  */

  var cookieKey = 'collapsible-details',
      currentState = Cookies.get(cookieKey);

  function handleCollapseClasses(e) {
    var target = e.originalEvent.data.newBody || document,
        $target = $(target),
        isHidden = currentState == 'hidden';
    $target.find('#collapsible-details-toggler').toggleClass('collapsed', isHidden);
    $target.find('#collapsible-details').toggleClass('in', !isHidden);
  }

  // set listeners on document
  $(document)
    .on('show.bs.collapse', '#collapsible-details', function () {
      currentState = 'shown';
      Cookies.set(cookieKey, currentState, { expires: 365 });
    })
    .on('hide.bs.collapse', '#collapsible-details', function () {
      currentState = 'hidden';
      Cookies.set(cookieKey, currentState, { expires: 365 });
    })
    .on('turbolinks:before-render', handleCollapseClasses)
    .on('turbolinks:load', handleCollapseClasses);

}(jQuery));
