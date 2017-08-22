/*jslint vars:true, nomen: true, white: true, browser: true*/
/*global $*/
/*global Mustache*/

'use strict';

$(document).ready(function() {
    var lastfmURL = 'https://ws.audioscrobbler.com/2.0/?method=user.gettopalbums&user=sharkdp&api_key=8f892de4deca9e6ef1d3e10224019a3a&format=json&period=12month';
    $.getJSON(lastfmURL, function(res) {
        var container = $("#gamesContainer");

        if (!res) {
            container.html('<font color="red">AJAX call to lastfm.com failed.</font>');
            return;
        }

        var items = res.topalbums.album;

        var out;
        var template = $("#albumTemplate").html();
        Mustache.parse(template);

        var html = '<div class="row">';
        $.each(items, function(i, item) {
            if (i % 2 === 0 && i !== 0) {
                html = html.concat('</div><div class="row">');
            }

            item.cover = item.image[3]["#text"];

            out = Mustache.render(template, item);
            html = html.concat(out);
        });
        html = html.concat('</div>');

        container.html(html);
    });
});
