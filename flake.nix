{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      packages = forAllSystems (
        system: with import nixpkgs { inherit system; }; {
          default =

            stdenv.mkDerivation {
              pname = "gltf-ibl-sampler";
              version = "unstable";

              src = fetchFromGitHub {
                owner = "KhronosGroup";
                repo = "glTF-IBL-Sampler";
                rev = "08fa12250f6f5f5969c1846aaa266e6eea887731";
                fetchSubmodules = true;
                hash = "sha256-6yvl55ESLNwgxDcpQoiA3+186nx94uw3vb9WO7DKzvw=";
              };

              patches = [
                ./0001-nix-use-ktx-tools-from-nixpkgs.patch
              ];

              cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ]; # upstream asks for cmake 3.12, cmake 4 refuses

              preBuild = ''
                rm -rf thirdparty/KTX-Software
              '';

              nativeBuildInputs = [
                cmake
                gcc
              ];

              buildInputs = [
                shaderc
                glslang
                glslang.dev
                ktx-tools
                vulkan-loader
                vulkan-validation-layers
                vulkan-headers
              ];

              meta = with lib; {
                description = "Take HDR, yeet KTX2 Cubemap";
                homepage = "https://github.com/KhronosGroup/glTF-IBL-Sampler";
                maintainers = with maintainers; [ grindhold ];
                license = licenses.asl20;
                platforms = platforms.unix;
              };
            };
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/cli";
        };
      });

      devShell = forAllSystems (
        system:
        with import nixpkgs { inherit system; };
        mkShell {
          name = "glTF-IBL-Sampler shell";
          buildInputs = [
            git
            cmake
            gcc
            shaderc
            glslang
            glslang.dev
            ktx-tools
            vulkan-loader
            vulkan-validation-layers
            vulkan-headers
          ];
        }
      );
    };
}
