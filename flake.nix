{
  description = "Nix flake that generates a configuration derivation and provides mitogen";
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
  };

  outputs = { self, nixpkgs-stable }:
  {

  defaultPackage.x86_64-linux =
    let
      pkgs = import nixpkgs-stable { system = "x86_64-linux"; };
    in pkgs.stdenv.mkDerivation {
      name = "ansible-mitogen";
      srcs = [
        (builtins.fetchTarball {
          url = "https://files.pythonhosted.org/packages/source/m/mitogen/mitogen-0.2.9.tar.gz";
          sha256 = "1pzrc39mv363b3fcr2y2zhx3zx9l49azz65sl1j4skf4h4fhdj08";
          name = "mitogen";
        })
        self
      ];

      sourceRoot = "mitogen";

      installPhase = "mkdir -p $out; cp -r ./ansible_mitogen $out; sed s#install#$out#g ../source/ansible.tmpl > $out/ansible.cfg";
    };
  };
}
