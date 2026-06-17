# love-native-modules

A small outer CMake frame for building native Lua/LuaJIT modules for
https://love2d.org/ alongside a local https://github.com/love2d/megasource
checkout.

The goal is to keep LOVE, megasource, and local native modules in one build
tree without making this repository own those checkouts.

## Layout

```text
love-native-modules/
  megasource/  # local clone of love2d/megasource
    libs/
      love/    # local clone of love2d/love, as expected by megasource
  modules/     # local native modules to build alongside LOVE
  build/       # generated build tree for LOVE and modules
  examples/    # tracked usage examples for this wrapper
```

`megasource/`, `modules/`, and `build/` are intentionally ignored by git.

## Clone Megasource And LOVE

From this repository root:

```powershell
git clone https://github.com/love2d/megasource.git megasource
git clone https://github.com/love2d/love.git megasource/libs/love
```

This follows the megasource convention: the LOVE source tree lives inside
`megasource/libs/love`, and megasource ignores that inner checkout so the two
repositories do not get mixed together.
