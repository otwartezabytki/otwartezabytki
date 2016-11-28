/**
 * Created by fryderyk on 02.11.16.
 */
$(document).ready(function () {
    var do_remove = $('.js-remove-their-container').css("content");
    if (do_remove.length > 0) {
        $('.their-container').removeClass("their-container");
    }
})