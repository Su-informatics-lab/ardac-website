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

    // Smooth scroll to top for the Back to Top tag
    $('.back-top-tag a').on('click', function (e) {
        e.preventDefault();
        $('html, body').animate({ scrollTop: 0 }, 300);
    });
});
