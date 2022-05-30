(function($) {
  /*
    Handle remote modals
  */

  function handleRemoteModal(e) {
    // ensure next modal toggle correctly replaces the content
    $(this).removeData();
  }

  // set listeners on document
  $(document)
    .on('hide.bs.modal', '.modal-remote', handleRemoteModal);

}(jQuery));
