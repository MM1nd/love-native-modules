cmake_minimum_required(VERSION 3.10)

get_filename_component(LOVE_NATIVE_MODULES_EXPECTED_BINARY_DIR
	"${CMAKE_CURRENT_SOURCE_DIR}/build" ABSOLUTE)
get_filename_component(LOVE_NATIVE_MODULES_ACTUAL_BINARY_DIR
	"${CMAKE_BINARY_DIR}" ABSOLUTE)

if(NOT LOVE_NATIVE_MODULES_ACTUAL_BINARY_DIR STREQUAL LOVE_NATIVE_MODULES_EXPECTED_BINARY_DIR)
	message(FATAL_ERROR
		"This wrapper expects its build tree at ${LOVE_NATIVE_MODULES_EXPECTED_BINARY_DIR}.\n"
		"Use: cmake --preset vs2022-x64")
endif()

project(love-native-modules)

set(LOVE_NATIVE_MODULES_MEGASOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/megasource")

if(NOT EXISTS "${LOVE_NATIVE_MODULES_MEGASOURCE_DIR}/CMakeLists.txt")
	message(FATAL_ERROR
		"Missing megasource checkout. Clone it with:\n"
		"  git clone https://github.com/love2d/megasource.git megasource")
endif()

add_subdirectory("${LOVE_NATIVE_MODULES_MEGASOURCE_DIR}" megasource)

set(LOVE_NATIVE_MODULES_DIST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/dist")

if(NOT TARGET luajit)
	message(FATAL_ERROR "Expected megasource to expose the LuaJIT target")
endif()

get_target_property(LOVE_NATIVE_MODULES_LUAJIT_INCLUDE luajit INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(LOVE_NATIVE_MODULES_LUAJIT_LIB luajit IMPORTED_IMPLIB)

if(NOT LOVE_NATIVE_MODULES_LUAJIT_INCLUDE OR NOT LOVE_NATIVE_MODULES_LUAJIT_LIB)
	message(FATAL_ERROR "Expected megasource's LuaJIT target to expose includes and import library")
endif()

include(cmake/LoveNativeModules.cmake)

if(TARGET love)
	add_custom_target(package-love-runtime
		COMMAND "${CMAKE_COMMAND}"
			"-DLOVE_RUNTIME_SOURCE_DIR=${CMAKE_BINARY_DIR}/love/$<CONFIG>"
			"-DLOVE_RUNTIME_PACKAGE_DIR=${LOVE_NATIVE_MODULES_DIST_DIR}/love/$<CONFIG>"
			-P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/package-love-runtime.cmake"
		DEPENDS love
		COMMENT "Copying LOVE runtime files to dist/love/$<CONFIG>")
endif()

add_subdirectory(modules)
add_subdirectory(examples)
