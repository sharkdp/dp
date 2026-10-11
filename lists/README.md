# Board-game collection endpoint

`collection.php` reads two environment variables:

- `BGG_CONFIG`: absolute path to a private PHP file defining `$token`, the
  BoardGameGeek API token. Keep it outside the public document root and Git.
- `BGG_CACHE`: absolute path to the writable JSON cache. Its parent directory
  must be writable by the PHP service for atomic replacement.

The cache refreshes on demand after 24 hours. If the upstream request fails,
the previous cache is served; without a cache, the endpoint returns HTTP 503.
The token must be restored separately after reinstalling; the cache can be
regenerated. `config.php` and `collection.json` are ignored by Git.
