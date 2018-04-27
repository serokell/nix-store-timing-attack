I'm not sure how important this is, but here's a timing attack on binary cache that
allows attacker to recover a potentially private path from cache's Nix store. Maybe
that's intended, still worth noting.

To get the right numbers, `lp7x6ziq5b2zihgad0i8a28xxvz5vnrr` (Python 3.6) has to be
present in Nix store of the box that's running the test. If it isn't, just edit `script.pl`
and replace that hash and half-zeroed hash accordingly to any other existing hash.

I'm getting approximately 3% difference between zeroed out hash and existing hash,
this seems to be enough to be abusable over LAN (e.g. by renting an instance in the
same data center).

1% accounts for SQLite lookup, and the other 2% seem to be caused by this check:
https://github.com/NixOS/nix/blob/d34fa2bcc3572fafc893755cee19d97aed7ec649/src/libstore/local-store.cc#L830

Isolated SQLite timing test for the query used by `queryPathFromHashPart`
(has to run as root):

```
#include <stdlib.h>
#include <sqlite3.h>

int main() {
 sqlite3 *db;
 sqlite3_open("/nix/var/nix/db/db.sqlite", &db);

 for (size_t i = 0; i < 1000000; i++) {
   sqlite3_stmt *stmt;
   const char *tail;

   sqlite3_prepare(db, "select path from ValidPaths where path >= ? limit 1;", 1000, &stmt, &tail);

   /* Uncomment one of two: */
   
   // zeroed out hash
   // sqlite3_bind_text(stmt, 1, "/nix/store/00000000000000000000000000000000", -1, SQLITE_STATIC);
   
   // ruby hash (replace with any existing hash)
   // sqlite3_bind_text(stmt, 1, "/nix/store/zdp5pffzl7yiy1qgnj33kcbbxmz7p48p", -1, SQLITE_STATIC);

   sqlite3_step(stmt);
   sqlite3_finalize(stmt);
 }
}
```

Build via `nix-shell -p gcc pkgconfig sqlite --run 'gcc cache-timing-attack.c $(pkg-config --cflags --libs sqlite3)'`.

### Proposed mitigations

* making string comparison in `local-store.cc#L830` constant-time
* keeping track of how long does `queryPathFromHashPart` take and
  making it always return at least after that amount of time
  (this can be done in Hydra and nix-serve)
* alternatively, making it clear that binary caches have this property

### Disclosure

If at all possible, it would be nice to give us some time to fix
[nix-cache](https://github.com/serokell/nix-cache).
