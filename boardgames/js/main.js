/*jslint vars:true, nomen: true, white: true, browser: true*/
/*global $*/
/*global Mustache*/

'use strict';

var shortTitle = {
    'Im Wandel der Zeiten: Eine Geschichte der Zivilisation': 'Im Wandel der Zeiten',
    'Pandemie: Auf Messers Schneide': 'Pandemie',
    "Time's up! Blaue Edition": "Time's up!",
    'Confusion: Espionage and Deception in the Cold War': 'Confusion',
    'Uluru: Tumult am Ayers Rock': 'Uluru'
};

$(document).ready(function() {
    $.getJSON("collection.php", function(res) {
        var container = $("#gamesContainer");

        if (!res) {
            container.html('<font color="red">AJAX call to boardgamegeek.com failed.</font>');
            return;
        }

        // Only games I really own:
        var items = [];
        $.each(res, function(i, item) {
            // numeric rating, rounded to two digits
            item.rating = Math.round(item.rating * 100) / 100;
            console.log(item);

            // players
            var min = item.minplayers;
            var max = item.maxplayers;
            if (min === max) {
                item.players = min;
            } else {
                item.players = min.toString().concat("-").concat(max.toString());
            }

            // title
            var title = item.name;
            if (shortTitle.hasOwnProperty(title)) {
                item.title = shortTitle[title];
            } else {
                item.title = title;
            }
            items.push(item);
        });

        // Sort by rating
        items.sort(function(a, b) {
            return b.rating - a.rating;
        });

        var out;
        var template = $("#gameTemplate").html();
        Mustache.parse(template);

        var html = '<div class="row">';
        $.each(items, function(i, item) {
            if (i % 2 === 0 && i !== 0) {
                html = html.concat('</div><div class="row">');
            }

            out = Mustache.render(template, item);
            html = html.concat(out);
        });
        html = html.concat('</div>');

        container.html(html);
    });
});
