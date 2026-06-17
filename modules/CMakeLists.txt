add_custom_target(modules-release)
add_custom_target(modules-package)
add_dependencies(modules-release modules-package)

if(TARGET package-love-runtime)
	add_dependencies(modules-release package-love-runtime)
endif()

set(LOVE_NATIVE_MODULES_PACKAGE_AGGREGATE modules-package)

file(GLOB LOVE_NATIVE_MODULES_MODULE_DIRS
	CONFIGURE_DEPENDS
	RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
	"*")

foreach(LOVE_NATIVE_MODULES_MODULE_DIR IN LISTS LOVE_NATIVE_MODULES_MODULE_DIRS)
	if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${LOVE_NATIVE_MODULES_MODULE_DIR}"
		AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${LOVE_NATIVE_MODULES_MODULE_DIR}/CMakeLists.txt")
		add_subdirectory("${LOVE_NATIVE_MODULES_MODULE_DIR}")
	endif()
endforeach()
