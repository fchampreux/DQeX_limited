(function($) {
  /*
    Handle notifications
  */

  var defaultDuration = 10 * 1000,
      ct = $('#notifications'),
      closeBtn = $('<button/>', {
        class: 'close',
        html: '&times;',
        type: 'button',
        role: 'button',
        ariaHidden: 'true'
      }).data('dismiss', 'alert'),
      notificationTemplate = $('<li/>', {
        class: 'alert',
        role: 'alert'
      }).append(closeBtn);

  function closeNotification(notification) {
    clearTimeout(notification.data('timeoutIdx'));

    notification.slideUp(function () {
      notification.remove();
    });
  }

  function handleNotification(e, data) {
    var notification =
      notificationTemplate.clone()
        .addClass('alert-' + data.type)
        .append(data.message)
        .hide(),
        timeout = data.timeout || defaultDuration;

    $('#notifications').append(notification.fadeIn());

    timeoutIdx = setTimeout(closeNotification.bind(null, notification), timeout);
    notification.data('timeoutIdx', timeoutIdx);
  }

  function handleClose() {
    closeNotification($(this).closest('.alert'));
  }

  // set listeners on document
  $(document)
    .on('proto.notification', handleNotification)
    .on('click', '.alert .close', handleClose);

}(jQuery));
