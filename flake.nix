{
  description = "docker c++ builder (using nix)";

  # dependencies
  inputs = rec {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
  };

  # see also ~/public_html/flake.nix

  outputs = { self, nixpkgs } :
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

#      hello_deriv = pkgs.writeShellScriptBin "entrypoint.sh" ''
#        echo "Hello $1"
#        time=$(date)
#        echo "time=$time" >> $GITHUB_OUTPUT
#      '';

      docker_builder_deriv =
        pkgs.dockerTools.buildLayeredImage {
          name = "docker-cpp-builder";
          tag = "v2";
          contents = [ self.packages.${system}.git
                       self.packages.${system}.cacert
                       self.packages.${system}.gnumake
                       self.packages.${system}.gcc
                       self.packages.${system}.binutils
                       self.packages.${system}.bash
                       # for /bin/tail,  assumed by github actions when invoking a docker contianer
                       self.packages.${system}.coreutils ];

#          config = {
#            Cmd = [ "/bin/entrypoint.sh" ];
#            WorkingDir = "/";
#          };
        };

    in rec {
      packages.${system} = {
        default = docker_builder_deriv;

        docker_builder = docker_builder_deriv;

        git = pkgs.git;
        cacert = pkgs.cacert;
        gnumake = pkgs.gnumake;
        gcc = pkgs.gcc;
        binutils = pkgs.binutils;
        bash = pkgs.bash;
        #cmake = pkgs.cmake;
        # note: _all_ containers used for github actions will need this
        #       (of cource cmake/c++ need it anyway)
        coreutils = pkgs.coreutils;
      };
    };
}
