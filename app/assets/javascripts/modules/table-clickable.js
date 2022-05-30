(function($) {

  var interactiveThusIgnored = ['a','button','input','textarea','select']

  // add live listener to clicks on .table-clickable rows with a data-href attribute
  $(document).on('click auxclick contextmenu', '.table-clickable > tbody > tr[data-href]', function (e) {
    // get url
    var url = $(this).data('href'),
        targetTagName = e.target.tagName.toLowerCase();

    if (interactiveThusIgnored.includes(targetTagName))
      return true;

    switch (e.which) {
      // left click
      case 1:
        // simply follow link
        // window.location.assign(url); // not working properly with Turbolinks
        Turbolinks.visit(url);
        break;
      // middle click
      case 2:
        // open link in a blank page / tab
        $('<a />', {'href': url, 'target': '_blank'}).get(0).click();
        e.preventDefault();
        break;
      default:
        break;
    }
  });

}(jQuery));
