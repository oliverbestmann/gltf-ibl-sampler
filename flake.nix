{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  outputs = { self, nixpkgs } : 
  rec
  {
    system = "x86_64-linux";

    packages.x86_64-linux.default = 
    with import nixpkgs {inherit system;};

    stdenv.mkDerivation rec {
      pname = "gltf-ibl-sampler";
      version = "unstable";

      src = fetchFromGitHub {
        owner = "KhronosGroup";
        repo = "glTF-IBL-Sampler";
        rev = "08fa12250f6f5f5969c1846aaa266e6eea887731";
        fetchSubmodules = true;
        hash="sha256-6yvl55ESLNwgxDcpQoiA3+186nx94uw3vb9WO7DKzvw=";
      };

      patches = [
        ./0001-nix-use-ktx-tools-from-nixpkgs.patch
      ];

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

    apps.x86_64-linux.default = {
      type = "app";
      program = "${self.packages.x86_64-linux.default}/bin/cli";
    };

    devShell.x86_64-linux =
      with import nixpkgs {inherit system;};
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
    };
  };
}
