{
  haskell,
  haskellPackages,
  lib,
  runCommand,
  nixfmt-rfc-style,
}:
let
  inherit (haskell.lib.compose) overrideCabal justStaticExecutables;

  overrides = rec {
    version = "unstable-${lib.fileContents ./date.txt}";

    passthru.updateScript = ./update.sh;

    teams = [ lib.teams.formatter ];

    preBuild = ''
      echo -n 'nixpkgs-${version}' > .version
    '';

    # These tests can be run with the following command.
    #
    # $ nix-build -A nixfmt-rfc-style.tests
    passthru.tests =
      runCommand "nixfmt-rfc-style-tests" { nativeBuildInputs = [ nixfmt-rfc-style ]; }
        ''
          nixfmt --version > $out
        '';
  };
  raw-pkg = haskellPackages.callPackage ./generated-package.nix { };
in
lib.pipe raw-pkg [
  (overrideCabal overrides)
  justStaticExecutables
]
