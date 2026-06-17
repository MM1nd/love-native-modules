# love-native-modules

An outer CMake wrapper for building native Lua/LuaJIT modules alongside a
local https://love2d.org/ build from https://github.com/love2d/megasource.

The point is to keep access to the full LOVE build tree while also having a
clean place to sideload native modules and package a runnable LOVE runtime.
This repository owns the wrapper files; megasource, LOVE, modules, and build
outputs stay local.

This wrapper is intentionally opinionated: the folder names below are part of
the interface. In particular, CMake is expected to run from this repository root
and use `build/` as its build tree.

## Layout

```text
love-native-modules/
  megasource/  # local clone of love2d/megasource
    libs/
      love/    # local clone of love2d/love, as expected by megasource
  modules/     # local native modules to sideload/build alongside LOVE
  build/       # generated build tree for LOVE and modules
  dist/        # packaged runtime files copied out of build
  examples/    # tracked usage examples for this wrapper
```

`megasource/`, `modules/`, `build/`, and `dist/` are intentionally ignored by
git.

## Setup

From this repository root:

```powershell
git clone https://github.com/love2d/megasource.git megasource
git clone https://github.com/love2d/love.git megasource/libs/love
```

This follows the megasource convention: the LOVE source tree lives inside
`megasource/libs/love`, and megasource ignores that inner checkout so the two
repositories do not get mixed together.

## Build

Run CMake from this repository root. The wrapper delegates to `megasource/`, and
the build tree is always `build/`.

```powershell
cmake --preset vs2022-x64
cmake --build --preset love-release
```

The full LOVE build output is written to `build/love/Release`, matching
megasource. This includes development files such as `.lib` outputs.

## Package

To copy just the runtime `.exe` and `.dll` files into a cleaner folder:

```powershell
cmake --build --preset package-love-runtime-release
```

The packaged runtime files are written to `dist/love/Release`.

## Verify

After packaging, check that the staged LOVE executable runs:

```powershell
.\dist\love\Release\love.exe --version
```

Expected output starts with:

```text
LOVE 12.0
```
