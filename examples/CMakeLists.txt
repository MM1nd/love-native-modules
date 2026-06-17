add_custom_target(examples-release)
add_custom_target(examples-package)
add_dependencies(examples-release examples-package)

if(TARGET package-love-runtime)
	add_dependencies(examples-release package-love-runtime)
endif()

set(LOVE_NATIVE_MODULES_PACKAGE_AGGREGATE examples-package)

file(GLOB LOVE_NATIVE_MODULES_EXAMPLE_DIRS
	CONFIGURE_DEPENDS
	RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
	"*")

foreach(LOVE_NATIVE_MODULES_EXAMPLE_DIR IN LISTS LOVE_NATIVE_MODULES_EXAMPLE_DIRS)
	if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${LOVE_NATIVE_MODULES_EXAMPLE_DIR}"
		AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${LOVE_NATIVE_MODULES_EXAMPLE_DIR}/CMakeLists.txt")
		add_subdirectory("${LOVE_NATIVE_MODULES_EXAMPLE_DIR}")
	endif()
endforeach()
