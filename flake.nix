{
  description = "Nix flake that generates a configuration derivation and provides mitogen";
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs-stable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs-stable { inherit system; };
      in
      rec {
        defaultPackage = pkgs.stdenv.mkDerivation
          {
            name = "ansible-mitogen";
            srcs = [
              (builtins.fetchTarball {
                url = "https://github.com/mitogen-hq/mitogen/archive/refs/tags/v0.2.10.tar.gz";
                sha256 = "110ppgvmnz7ykdx47x33c0rb7zq3fkrw6g699c4vqa28mn00qp28";
                name = "mitogen";
              })
              self
            ];

            sourceRoot = "mitogen";

            installPhase = "mkdir -p $out; cp -r ./ansible_mitogen $out; sed s#install#$out#g ../source/ansible.tmpl > $out/ansible.cfg";
          };

        wrapMitogen = (ansible:
          ansible.overridePythonAttrs (old: {
            makeWrapperArgs = [ "--set ANSIBLE_CONFIG ${defaultPackage.outPath}/ansible.cfg" ];
          })
        );
      }
    );
}
