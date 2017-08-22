<?php
/* error_reporting(~0); */
/* ini_set('display_errors', 1); */

function showCachedResult() {
    print(file_get_contents("collection.json"));
    exit();
}

$bgg_api_url = 'https://boardgamegeek.com/xmlapi2/collection?username=sharkdp&own=1&stats=1';

$res = file_get_contents($bgg_api_url);
if (!$res) {
    showCachedResult();
}

$xml = simplexml_load_string($res);
if ($xml->error || !property_exists($xml, 'item')) {
    showCachedResult();
}

/* print_r($xml); */

$games = array();
foreach($xml->item as $it) {
    array_push($games, array(
        "bggid" => (int) $it["objectid"],
        "name" => (string) $it->name,
        "year" => (int) $it->yearpublished,
        "minplayers" => (int) $it->stats["minplayers"],
        "maxplayers" => (int) $it->stats["maxplayers"],
        "time" => (int) $it->stats["playingtime"],
        "thumb" => (string) $it->thumbnail,
        "rating" => (float) $it->stats->rating->average["value"]
    ));
}

$json = json_encode($games);

$f = fopen("collection.json", "w");
fwrite($f, $json);
fclose($f);

print($json);
?>
