# love-native-modules

An opinionated CMake wrapper for building native Lua/LuaJIT modules against a
local https://love2d.org/ build from https://github.com/love2d/megasource.

The purpose is ABI alignment. A native module should compile against the same
LuaJIT headers, link against the same `lua51.lib`, load beside the same
`lua51.dll`, and use the same configured compiler/linker toolchain as the
packaged LOVE runtime. This wrapper makes that the default path instead of
something every module has to rediscover.

On Windows/MSVC, this matters because the LuaJIT import library and native
module DLLs should be produced by the same Visual Studio toolchain family. The
wrapper configures LOVE and modules in one CMake build so they share the same
generator, architecture, compiler, linker, and runtime assumptions.

## Shape

This repository owns the wrapper CMake, helper functions, the `modules/`
dispatcher, and tracked examples. The large or local pieces stay outside git:

```text
love-native-modules/
  megasource/  # local clone of love2d/megasource
    libs/
      love/    # local clone of love2d/love, as expected by megasource
  modules/     # tracked dispatcher; ignored local module projects inside it
  build/       # generated build tree for LOVE and modules
  dist/        # packaged LOVE runtime and selected module binaries
  examples/    # tracked self-checks and usage examples
```

The folder names are part of the interface. CMake is expected to run from this
repository root and use `build/` as its build tree. `build/` keeps the full
development output; `dist/` is the cleaner runnable view.

The `modules/` folder has a tracked `CMakeLists.txt` owned by this wrapper. It
discovers local module subdirectories with their own `CMakeLists.txt`; those
module subdirectories are ignored by git.

## Setup

From this repository root:

```powershell
git clone https://github.com/love2d/megasource.git megasource
git clone https://github.com/love2d/love.git megasource/libs/love
```

This follows megasource's convention: LOVE lives inside `megasource/libs/love`,
and megasource ignores that inner checkout.

## Build LOVE

```powershell
cmake --preset vs2022-x64
cmake --build --preset love-release
```

`love-release` builds through megasource and packages the runnable LOVE runtime
to `dist/love/Release`. The full build output remains in `build/love/Release`,
including development files such as `.lib` outputs.

`dist/love/Release` is the stable local runtime location for this wrapper. During
development, point scripts or PATH entries there instead of at an official LOVE
install if you want to run against the same locally built runtime and native
modules.

## Native Modules

Drop local modules under `modules/`. Each module owns its own `CMakeLists.txt`
and should declare only its sources and output name:

```cmake
add_love_native_module(my-module
	OUTPUT_NAME mymodule
	SOURCES mymodule.c)
```

The wrapper supplies the LuaJIT include directory, import library, build
dependency, package destination, and active C/C++ toolchain from the same CMake
configuration that builds LOVE. Packaged module DLLs are copied next to
`love.exe` in `dist/love/Release`, so Lua can load them with plain
`require("mymodule")`.

Build and package all local modules:

```powershell
cmake --build --preset modules-release
```

## Examples

Examples are tracked self-checks for the build environment, not part of the
default LOVE runtime package. Each example owns its own `CMakeLists.txt`, and
`examples-release` builds and packages all examples:

```powershell
cmake --build --preset examples-release
```

The `hello-native` example is intentionally small. Its CMake is:

```cmake
add_love_native_module(hello-native
	OUTPUT_NAME hello
	SOURCES hello.c)
```

Run it from the source tree:

```powershell
.\dist\love\Release\love.exe --console .\examples\hello-native
```

The `--console` flag makes `print` output visible on Windows.

## Verify LOVE

Check that the staged LOVE executable runs:

```powershell
.\dist\love\Release\love.exe --version
```

Expected output starts with:

```text
LOVE 12.0
```

For a deeper check, run one of LOVE's own source tests against the packaged
runtime:

```powershell
.\dist\love\Release\love.exe .\megasource\libs\love\testing\main.lua --console --modules love
```

The test app exits when it finishes and writes report files under
`megasource/libs/love/testing/output`.

## TODO

- Decide whether to support multiple generators/toolchains side by side. The
  current wrapper intentionally has one blessed CMake preset and one `build/`
  plus `dist/` layout. Supporting toolchains such as a future Visual Studio
  version at the same time would likely require generator-specific build and
  dist folders to avoid preset sprawl and accidental ABI/toolchain mixing.
- Decide how to support debugging native modules in context. The useful case is
  stepping through a module DLL while it is loaded by the local LOVE runtime,
  without necessarily debugging or rebuilding LOVE itself.

## Prior Art

- [Nigh/Dll_for_Love2D_sample](https://github.com/Nigh/Dll_for_Love2D_sample)
  shows the basic shape of a native Lua module for LOVE: export `luaopen_*`,
  place the DLL where `require` can find it, and call it from Lua. This wrapper
  keeps that loading model, but avoids vendored or mismatched Lua headers/libs by
  deriving them from the local megasource build.
