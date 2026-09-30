$(function () {
    // Read More toggle (only visible on mobile via CSS)
    $('.readMore').on('click', function () {
        var $more = $(this).prev('.moreText');
        if ($more.is(':visible')) {
            $more.hide();
            $(this).text('... Read More');
        } else {
            $more.show();
            $(this).text(' Read Less');
        }
    });

    // Collapse mobile nav after clicking a link
    $('.navbar-nav .nav-link').on('click', function () {
        if ($('.navbar-toggler').is(':visible')) {
            $('#mainNav').collapse('hide');
        }
    });

    var $newsItems = $('.news-timeline details');
    function allNewsOpen() {
        return $newsItems.not('[open]').length === 0;
    }
    function syncNewsToggleLabel() {
        $('.news-toggle-all').text(allNewsOpen() ? 'Collapse all' : 'Expand all');
    }
    $('.news-toggle-all').on('click', function () {
        $newsItems.prop('open', !allNewsOpen());
        syncNewsToggleLabel();
    });
    $newsItems.on('toggle', syncNewsToggleLabel);

    // Smooth scroll to top for the Back to Top tag
    $('.back-top-tag a').on('click', function (e) {
        e.preventDefault();
        $('html, body').animate({ scrollTop: 0 }, 300);
    });
});
