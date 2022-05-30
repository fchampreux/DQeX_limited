$(function () {
  // handle turbolinks page change
  $(document)
    .on('turbolinks:load', function (e) {
      // create translation <div>
      $('.translation-block').each(function () {
        var block = $(this),
            rows = block.find('.row').not(':first');
          rows.wrapAll('<div class="translation" />');
      });
    })
    .on('click', '#translation-toggler', function() {
      var btn = $(this),
          blocks = $(".translation"),
          ct = blocks.closest('.translation-block'),
          isActive = btn.hasClass('active');

      if (isActive) {
        blocks.slideUp(250);
      } else {
        blocks.slideDown(250);
      }

      btn.toggleClass('active', !isActive);
      ct.toggleClass('active', !isActive);
    });
});
