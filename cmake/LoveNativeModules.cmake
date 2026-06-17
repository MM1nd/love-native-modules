function(add_love_native_module TARGET)
	cmake_parse_arguments(ARG "" "OUTPUT_NAME" "SOURCES" ${ARGN})

	if(NOT ARG_SOURCES)
		message(FATAL_ERROR "add_love_native_module(${TARGET}) requires SOURCES")
	endif()

	add_library(${TARGET} MODULE ${ARG_SOURCES})
	set_target_properties(${TARGET} PROPERTIES PREFIX "")

	if(ARG_OUTPUT_NAME)
		set_target_properties(${TARGET} PROPERTIES OUTPUT_NAME "${ARG_OUTPUT_NAME}")
	endif()

	target_include_directories(${TARGET} PRIVATE ${LOVE_NATIVE_MODULES_LUAJIT_INCLUDE})
	target_link_libraries(${TARGET} PRIVATE ${LOVE_NATIVE_MODULES_LUAJIT_LIB})
	add_dependencies(${TARGET} luajit)

	package_love_native_module(${TARGET})

	if(LOVE_NATIVE_MODULES_PACKAGE_AGGREGATE)
		add_dependencies(${LOVE_NATIVE_MODULES_PACKAGE_AGGREGATE} package-${TARGET})
	endif()
endfunction()

function(package_love_native_module TARGET)
	add_custom_target(package-${TARGET}
		COMMAND "${CMAKE_COMMAND}" -E make_directory
			"${LOVE_NATIVE_MODULES_DIST_DIR}/love/$<CONFIG>"
		COMMAND "${CMAKE_COMMAND}" -E copy_if_different
			"$<TARGET_FILE:${TARGET}>"
			"${LOVE_NATIVE_MODULES_DIST_DIR}/love/$<CONFIG>/$<TARGET_FILE_NAME:${TARGET}>"
		DEPENDS ${TARGET}
		COMMENT "Copying ${TARGET} native module to dist/love/$<CONFIG>")
endfunction()
