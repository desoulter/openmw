if (APPLE)
    set(OPENMW_APP "OpenMW")
    set(OPENMW_CS_APP "OpenMW-CS")

    set(APPLICATIONS "${OPENMW_APP}" "${OPENMW_CS_APP}")
    foreach(app_name IN LISTS APPLICATIONS)
        set(FULL_APP_PATH "${CPACK_TEMPORARY_INSTALL_DIRECTORY}/ALL_IN_ONE/${app_name}.app")
        message(STATUS "Re-signing ${app_name}.app")

        # Handle osgPlugins directory
        file(GLOB OSG_PLUGINS_DIR "${FULL_APP_PATH}/Contents/PlugIns/osgPlugins*")
        if (EXISTS "${OSG_PLUGINS_DIR}")
            file(RENAME "${OSG_PLUGINS_DIR}" "${FULL_APP_PATH}/Contents/PlugIns/osgPlugins")
            execute_process(COMMAND "ln" "-s" "osgPlugins" "${OSG_PLUGINS_DIR}"
                            WORKING_DIRECTORY "${FULL_APP_PATH}/Contents/PlugIns/")
        endif()

        # Code signing
        execute_process(COMMAND "codesign" "--force" "--deep" "-s" "-" "${FULL_APP_PATH}"
                        RESULT_VARIABLE CODE_SIGN_RESULT)
        if (CODE_SIGN_RESULT)
            message(FATAL_ERROR "Code signing failed for ${app_name}.app")
        endif()
    endforeach(app_name)
endif (APPLE)