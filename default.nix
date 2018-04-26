with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "cache-timing-attack";

  buildInputs = [ nix.perl-bindings perl perlPackages.DBDSQLite perlPackages.TimeHiRes ];

  unpackPhase = ":";

  inherit perl;
  script = ./script.pl;

  installPhase = ''
    mkdir -p $out/bin
    substituteAll ${./wrapper.sh} $out/bin/cache-timing-attack
    chmod +x $_
    substituteInPlace $_ --subst-var-by PERL5LIB $PERL5LIB
  '';
}
