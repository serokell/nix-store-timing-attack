I'm not sure how important this is, but here's a timing attack on binary cache that
allows attacker to recover a potentially private path from cache's Nix store. 

To get the right numbers, /nix/store/lp7x6ziq5b2zihgad0i8a28xxvz5vnrr-* (Python 3.6)
has to be present on the box that's running the test. If it isn't, just edit `script.pl`
and replace that hash and half-zeroed hash accordingly to any other hash.

I'm getting approximately 3% difference between zeroed out hash and existing hash,
this seems to be enough to be abusable over LAN (e.g. by renting an instance in the
same data center).

1% accounts for SQLite lookup, and the other 2% seem to be caused by this check:
https://github.com/NixOS/nix/blob/d34fa2bcc3572fafc893755cee19d97aed7ec649/src/libstore/local-store.cc#L829

Proposed mitigations:

* making string comparison in `local-store.cc#L829` constant-time
* keeping track of how long does `queryPathFromHashPart` take and
  making it always return at least after that amount of time
