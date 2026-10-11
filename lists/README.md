# Board-game collection

The page loads `collection.json`, served directly by Caddy. A daily systemd
job on pink runs `update-collection.py` to fetch the BoardGameGeek collection.
The updater needs Python 3 and its standard library:

```sh
python3 update-collection.py --token-file /path/to/bgg-token --output /path/to/collection.json
```

The token file contains only the private BGG API token. Keep it outside Git
and the public document root. On pink, systemd loads it from
`/var/lib/dp-collection/bgg-token` as a service credential. The output is
`/var/lib/dp-collection/public/collection.json`.

The updater retries queued requests and transient HTTP errors, validates the
response, and atomically replaces the JSON. Failure preserves the last good
file. A valid empty collection produces an empty array. The NixOS configuration
in `pink-nixos/services/david-peter.nix` defines the service, timer and Caddy
route. `/lists/collection.php` remains an alias for older page versions.

The token must be restored separately after reinstalling; the JSON can be
regenerated. Legacy `config.php` and `collection.json` files remain ignored by Git.
