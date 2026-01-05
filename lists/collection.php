<?php
error_reporting(~0);
ini_set('display_errors', 1);

// API key requested here: https://boardgamegeek.com/applications

require_once('config.php');

$cache_file = "collection.json";
$cache_max_age = 24 * 60 * 60; // 24 hours in seconds

function showCachedResult($reason = "unknown") {
    global $cache_file;
    if (!file_exists($cache_file)) {
        die("Error: $reason (no cache available)");
    }
    print(file_get_contents($cache_file));
    exit();
}

// Use cache if it exists and is less than 24 hours old
if (file_exists($cache_file) && (time() - filemtime($cache_file) < $cache_max_age)) {
    showCachedResult();
}

$bgg_api_url = 'https://boardgamegeek.com/xmlapi2/collection?username=sharkdp&own=1&stats=1';

$context = stream_context_create([
    'http' => [
        'header' => "Authorization: Bearer $token\r\n"
    ]
]);

$res = file_get_contents($bgg_api_url, false, $context);
if (!$res) {
    showCachedResult("API request failed");
}

$xml = simplexml_load_string($res);
if (!$xml) {
    showCachedResult("XML parsing failed");
}
if ($xml->error) {
    showCachedResult("API error: " . $xml->error);
}
if (!property_exists($xml, 'item')) {
    showCachedResult("No items in response");
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
