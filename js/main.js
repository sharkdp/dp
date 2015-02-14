$(document).ready(function() {
    $('p').each(function() {
        $(this).addClass('hyphenate');
    });
    Hyphenator.run();
});
