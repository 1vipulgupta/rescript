{
    description = "Basic flake with mkDerivation";
    inputs = {
        nixpkgs = {
            url = "github:NixOS/nixpkgs";
        };
        flake-utils = { url = "github:numtide/flake-utils"; };
    };
    outputs = {self, nixpkgs, flake-utils, ...}:
        flake-utils.lib.eachDefaultSystem (system: let
            overlay =
                  (final: prev: {
                    rescript = prev.nodePackages.rescript.override {
                        src = prev.fetchFromGitHub {
                            owner = "rescript-lang";
                            repo = "rescript-compiler";
                            rev = "e0921fa9e67bdf5c7ee301599689db1d9b9894b6";
                            sha256 = "07vkzdq7qwy5djm37jaxld5m9d55d5aa6bw5s286gm4r139102q4";
                          };
                    };
                  });
            pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };#nixpkgs.legacyPackages.${system};
            in
            {   # nix develop
                # defaultPackage = pkgs.mkShell { #create a new shell with hook > compiles main.rs as run ./main
                #                                 buildInputs = [ pkgs.cargo pkgs.rustc ];
                #                                 inputsFrom = [ ];
                #                                 shellHook = ''
                #                                     export DEBUG=1
                #                                     rustc main.rs
                #                                     ./main
                #                                     rm main
                #                                 '';
                #                               };
                packages.default = pkgs.stdenv.mkDerivation #nix run
                    {
                        name = "main";
                        builder = "${pkgs.bash}/bin/bash";
                        args = [ ./builder.sh ];
                        inherit (pkgs) coreutils nodejs;
                        src = ./.;
                        system = builtins.currentSystem;
                        PATH = "${pkgs.coreutils}/bin:${pkgs.nodejs}/bin:${pkgs.rescript}/bin";
                    };
            });
}