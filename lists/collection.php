<?php
// The BGG token and mutable cache are provisioned outside the Nix store.
header('Content-Type: application/json; charset=utf-8');
require getenv('BGG_CONFIG');
$cache = getenv('BGG_CACHE');
function cached() {
    global $cache;
    if (is_file($cache)) {
        readfile($cache);
    } else {
        http_response_code(503);
        echo json_encode(['error' => 'Collection temporarily unavailable']);
    }
    exit;
}
if (is_file($cache) && time() - filemtime($cache) < 86400) cached();
$context = stream_context_create(['http' => [
    'header' => "Authorization: Bearer $token\r\n",
    'timeout' => 15,
]]);
$response = @file_get_contents('https://boardgamegeek.com/xmlapi2/collection?username=sharkdp&own=1&stats=1', false, $context);
if ($response === false) cached();
libxml_use_internal_errors(true);
$xml = simplexml_load_string($response, 'SimpleXMLElement', LIBXML_NONET);
if ($xml === false || isset($xml->error) || !isset($xml->item)) cached();
$games = [];
foreach ($xml->item as $it) {
    $games[] = [
        'bggid' => (int)$it['objectid'], 'name' => (string)$it->name,
        'year' => (int)$it->yearpublished,
        'minplayers' => (int)$it->stats['minplayers'], 'maxplayers' => (int)$it->stats['maxplayers'],
        'time' => (int)$it->stats['playingtime'], 'thumb' => (string)$it->thumbnail,
        'rating' => (float)$it->stats->rating->average['value'],
    ];
}
$json = json_encode($games);
if ($json === false) cached();
$tmp = tempnam(dirname($cache), '.collection-');
if ($tmp !== false) {
    if (file_put_contents($tmp, $json) !== false) rename($tmp, $cache);
    if (is_file($tmp)) unlink($tmp);
}
echo $json;
