# love-native-modules

An opinionated CMake wrapper for building native Lua/LuaJIT modules against a
local https://love2d.org/ build from https://github.com/love2d/megasource.

The purpose is LuaJIT ABI alignment. A native module should compile against the
same LuaJIT headers, link against the same `lua51.lib`, and load beside the same
`lua51.dll` that the packaged LOVE runtime uses. This wrapper makes that the
default path instead of something every module has to rediscover.

## Shape

This repository owns the wrapper CMake, helper functions, and tracked examples.
The large or local pieces stay outside git:

```text
love-native-modules/
  megasource/  # local clone of love2d/megasource
    libs/
      love/    # local clone of love2d/love, as expected by megasource
  modules/     # ignored workspace for local/native module projects
  build/       # generated build tree for LOVE and modules
  dist/        # packaged LOVE runtime and selected module binaries
  examples/    # tracked self-checks and usage examples
```

The folder names are part of the interface. CMake is expected to run from this
repository root and use `build/` as its build tree. `build/` keeps the full
development output; `dist/` is the cleaner runnable view.

If `modules/CMakeLists.txt` exists locally, the outer wrapper includes it. Local
modules can use the same helper as the tracked examples while staying outside
this repository's history.

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

## Native Modules

Modules should declare only their own sources and output name:

```cmake
add_love_native_module(my-module
	OUTPUT_NAME mymodule
	SOURCES mymodule.c)
```

The wrapper supplies the LuaJIT include directory, import library, build
dependency, and package destination derived from the megasource build. Packaged
module DLLs are copied next to `love.exe` in `dist/love/Release`, so Lua can
load them with plain `require("mymodule")`.

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
