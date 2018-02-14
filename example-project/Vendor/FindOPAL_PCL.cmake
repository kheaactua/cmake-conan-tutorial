include(FindPackageHandleStandardArgs)

function(findLibraries outputVar path)  # Add list of names after all parameters
    set(output)
    foreach(ITR ${ARGN}) # ARGN holds all arguments to function after last named one
        set(libv "lib_${ITR}")
        unset(${libv} CACHE)
        find_library(${libv}
            NAMES ${ITR}
            PATHS ${path}
        )

        if (NOT "${${libv}}" STREQUAL "${libv}-NOTFOUND")
            list(APPEND output ${${libv}})
        endif()
    endforeach()
    set(${outputVar} ${output} PARENT_SCOPE)
endfunction()


if(NOT TARGET OPAL_PCL)

    # Because we're not using conan targets, manually grab all PCL dependencies

    # PCL
    findLibraries(libs ${CONAN_LIB_DIRS_PCL} ${CONAN_LIBS_PCL})
    list(APPEND PCL_LIBRARIES ${libs})

    # Libs
    set(VENDOR_LIBRARIES)
    foreach (v IN ITEMS FLANN QHULL BOOST)
        set(libs)
        set(var_dir  "CONAN_LIB_DIRS_${v}")
        set(var_libs "CONAN_LIBS_${v}")
        findLibraries(libs ${${var_dir}} ${${var_libs}})
        list(APPEND VENDOR_LIBRARIES ${libs})

        unset(var_libs)
        unset(var_dir)
        unset(libs)
    endforeach()

    set(ALL_INCLUDE_DIRS)
    list(APPEND ALL_INCLUDE_DIRS ${CONAN_INCLUDE_DIRS_EIGEN})
    list(APPEND ALL_INCLUDE_DIRS ${CONAN_INCLUDE_DIRS_FLANN})
    list(APPEND ALL_INCLUDE_DIRS ${CONAN_INCLUDE_DIRS_QHULL})
    list(APPEND ALL_INCLUDE_DIRS ${CONAN_INCLUDE_DIRS_BOOST})

    add_library(OPAL_PCL INTERFACE)
    set_property(TARGET OPAL_PCL PROPERTY INTERFACE_INCLUDE_DIRECTORIES        ${ALL_INCLUDE_DIRS})
    set_property(TARGET OPAL_PCL PROPERTY INTERFACE_SYSTEM_INCLUDE_DIRECTORIES ${ALL_INCLUDE_DIRS})

    message(STATUS "Found PCL")
    message(STATUS "   include path: ${CONAN_INCLUDE_DIRS_PCL}")
    message(STATUS "   lib path:     ${PCL_INCLUDE_DIRS}")
    message(STATUS "   libs:         ${PCL_LIBRARIES}")
    message(STATUS "   Dependencies: ${VENDOR_LIBRARIES}")
    target_link_libraries(OPAL_PCL INTERFACE
        ${OPAL_PCL_LIBRARIES}
        ${VENDOR_LIBRARIES}
    )

    unset(ALL_INCLUDE_DIRS)
    unset(VENDOR_LIBRARIES)
endif()

# vim: set ts=4 sw=4 sts=4 expandtab expandtab :
