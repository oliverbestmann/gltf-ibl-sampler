Nix flake for glTF-IBL-Sampler
==============================

or rather

Nix flake for the "make me a nice bevy cubemap skybox from a fancy hdr image"-program
-------------------------------------------------------------------------------------

The glTF-IBL-Sampler is a program meant to convert equilinear HDR images into ktx2 textures
and happens to be able to render cubemaps in particular. Exactly as we need them in bevy.

I spent 24 hours to get this running and thought i'd share this flake with you, as i want
no one to have to go through that patching stuff again.

This patch esentially

 - Patches some printf's that woudln't compile in the gcc in 24.11
 - Makes the package use ktx-tools from nixpkgs instead of compiling their own

And that being done it runs on nixos.

Usage
-----

In bevy you need the specular map of an hdr:

```
nix run .# -- -inputPath fancy_hdr_image.hdr -outCubeMap nice_bevy_cubemap_diffuse.ktx2 -distribution Lambertian -sampleCount 1024 -targetFormat R16G16B16A16_SFLOA
```

```
nix run .# -- -inputPath fancy_hdr_image.hdr -outCubeMap nice_bevy_cubemap_specular.ktx2 -distribution GGX -sampleCount 1024 -targetFormat R16G16B16A16_SFLOAT
```

Then move your resulting `nice_bevy_cubemap_specular.ktx2` and `nice_bevy_cubemap_diffuse.ktx2` to your bevy application's asset folder.
Add the following to your camera3d-entity:

```
Skybox {
    image: asset_server.load("nice_bevy_cubemap_specular.ktx"),
    brightness: 1000.0,
}
```

Enjoy the view.

Upstream
--------

The original project can be found at [https://github.com/KhronosGroup/glTF-IBL-Sampler](https://github.com/KhronosGroup/glTF-IBL-Sampler)
