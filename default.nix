with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "nix-cache-timing-attack";

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    nix.perl-bindings
    perl
    perlPackages.DBDSQLite
    perlPackages.TimeHiRes
  ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${perl}/bin/perl $out/bin/${name} \
      --add-flags ${./script.pl} \
      --set PERL5LIB $PERL5LIB
  '';
}
