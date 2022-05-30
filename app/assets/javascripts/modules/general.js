(function($) {
  /*
    General purpose script
  */

  function handleSelect2(e) {
    $('.select2-candidate').select2();
  }

  // set listeners on document
  $(document)
    .on('turbolinks:load', handleSelect2);

}(jQuery));
