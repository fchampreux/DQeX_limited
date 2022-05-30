(function($) {
  /*
    Handle left navigation toggle and initial state.
    Handle deployment of navigation based on breadcrumbs.
    Handle active classes on the nav.
  */

  var activeClass = 'active',
      activeSelector = '.' + activeClass,
      lastNavScroll = null;

  function scrollNavToLastActive(item) {
    var navCt = $('#left-navigation-content'),
        navCtTop = navCt.offset() ? navCt.offset().top : 0,
        lastActive = navCt.find('.active').last(),
        li = lastActive.length ? lastActive.closest('li') : navCt.find('li').first(),
        liTop = li.offset() ? li.offset().top : 0,
        liY = navCt.scrollTop() - navCtTop + liTop,
        scroll = liY - (navCt.height() - li.height()) / 2;

    navCt.stop().animate({ scrollTop: scroll}, 300);
  }

  function handleCrumb(currentCrumb) {
    var nextCrumb = currentCrumb.closest('li').next().find('a'),
        href = currentCrumb.attr('href'),
        match = $('#left-navigation').find('.nav-item').filter('[href="' + href + '"]'),
        matchLevel = match.data('navLevel'),
        matchParent = match.parent(),
        matchToggler = matchParent.find('.nav-link-toggler'),
        matchLoader = matchParent.find('.nav-link-loader');

        // add active class to matched element
        match.addClass(activeClass);

        // handle next level, if there is one
        if (nextCrumb.length && matchToggler.length) {
          // if the loader is present, children still need to be loaded
          if (matchLoader.length) {
            // set one time listener for sub-navigation load
            $(document).one('sis:navigation-loaded', function () {
              handleCrumb(nextCrumb);
            })
            // trigger click on loader
            matchLoader[0].click();
          } else {
            // handle next level
            handleCrumb(nextCrumb);
          }
        } else {
          setTimeout(scrollNavToLastActive, 500);
        }
  }

  // handle turbolinks page change
  $(document)
    .on('click', '.column-toggle-left', function () {
      $('#column-left').toggleClass('collapsed');
    })
    .on('click', '.column-toggle-right', function () {
      $('#column-right').toggleClass('collapsed');
    })
    .on('turbolinks:before-visit', function (e) {
      // keep track of last scroll position
      lastNavScroll = $('#left-navigation-content').scrollTop();
    })
    .on('turbolinks:load', function (e) {
      // get current page url
      var currentUrl = location.origin + location.pathname,
          firstCrumb = $('#breadcrumbs').find('a').slice(1).first(),
          hasLastScroll = lastNavScroll != null;

      // restore nav scroll
      if (hasLastScroll) {
        $('#left-navigation-content').scrollTop(lastNavScroll);
        lastNavScroll = null;
      }

      $('#left-navigation').find(activeSelector).removeClass(activeClass);

      // parse each breadcrumb and open navigation subsenquently
      handleCrumb(firstCrumb);

      // parse top links, set active class on the one matching the current url, if any
      if (location.pathname == '/') {
        lastActiveTop = $('#navigation').find('a').first().addClass('active');
      } else {
        $('#navigation').find('a').not(':first').each(function () {
          var link = $(this),
              href = link.attr('href');
          // break loop if match is found
          if (location.pathname.startsWith(href)) {
            lastActiveTop = link.addClass('active');
            return false;
          }
        });
      }
    });
}(jQuery));
