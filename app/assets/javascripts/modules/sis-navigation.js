(function( $ ) {
  /*
    jQuery plugin for handling left navigation lazy loading results
    Once the dedicated ERB partial is loaded, it will call the plugin with the results.
  */
  $.fn.sisNavigation = function(options) {

    var settings = $.extend({
            children: [],
            childLevelId: 'business_area',
            modal: null
        }, options);

    return this.each(function() {

      var ct = $(this),
          parent = ct.closest('li'),
          parentLoader = parent.find('.nav-link-loader'),
          parentToggler = parent.find('> .nav-link'),
          list = $('<ul class="nav-tree nav-toggle nav-bordered nav-hover expanded" role="tree"/>'),
          listItem = $('<li role="presentation"/>'),
          linkCt = $('<span class="nav-link-container"/>'),
          link = $('<a class="nav-link nav-item" role="treeitem" />'),
          code = $('<strong />'),
          childrenCt = $('<div class="collapse show" />'),
          toggler = $('<a class="nav-link nav-link-toggler has-child collapsed" data-toggle="collapse" />'),
          loader = $('<a class="nav-link-loader" format="js" data-remote="true" data-method="get" />');

      // discard parent loader
      parentLoader.remove();
      // add control class to the parent
      parent.addClass('sis-nav-loaded');

      // parse children
      $.each(settings.children, function (idx, child) {
        var li = listItem.clone(),
            span = linkCt.clone(),
            anchor = link.clone();

        list.append(li);
        li.append(span);

        anchor
          .html(child.name)
          .prepend(code.clone().text(child.code))
          .attr('href', child.url);

        if (settings.modal) {
          anchor.attr({
            'data-toggle': 'modal',
            'data-target': settings.modal
          });
        }

        span.append(anchor);

        if (child.hasChildren) {
          span.append(
            toggler.clone()
              .attr({
                'href': '#ui-nav-' + settings.childLevelId + '-' + child.id + '-children',
                'aria-controls': 'ui-nav-' + settings.childLevelId + '-' + child.id + '-children'
              }),
            loader.clone()
              .attr('href', child.loadUrl)
          );
          li.append(
            childrenCt.clone()
              .attr('id', 'ui-nav-' + settings.childLevelId + '-' + child.id + '-children')
          );
        }
      });

      ct
        // append newly created list to the container
        .append(list)
        // open the container
        .collapse('show');

      // trigger loaded event
      $(document).trigger('sis:navigation-loaded', [ this.id ]);
    });
  };

}(jQuery));
