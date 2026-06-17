#include <lua.h>
#include <lauxlib.h>

#ifdef _WIN32
#define LOVE_NATIVE_EXPORT __declspec(dllexport)
#else
#define LOVE_NATIVE_EXPORT
#endif

static int hello_message(lua_State *L)
{
	lua_pushliteral(L, "Hello from a native C module loaded by LOVE.");
	return 1;
}

static int hello_add(lua_State *L)
{
	lua_Number a = luaL_checknumber(L, 1);
	lua_Number b = luaL_checknumber(L, 2);
	lua_pushnumber(L, a + b);
	return 1;
}

LOVE_NATIVE_EXPORT int luaopen_hello(lua_State *L)
{
	lua_newtable(L);

	lua_pushcfunction(L, hello_message);
	lua_setfield(L, -2, "message");

	lua_pushcfunction(L, hello_add);
	lua_setfield(L, -2, "add");

	return 1;
}
