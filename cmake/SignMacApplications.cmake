# # Add an option to skip signing
# option(SKIP_SIGNING "Skip signing the macOS applications" ON)

# if (APPLE)
#     set(OPENMW_APP "OpenMW")
#     set(OPENMW_CS_APP "OpenMW-CS")

#     set(APPLICATIONS "${OPENMW_APP}" "${OPENMW_CS_APP}")
#     foreach(app_name IN LISTS APPLICATIONS)
#         set(FULL_APP_PATH "${CPACK_TEMPORARY_INSTALL_DIRECTORY}/ALL_IN_ONE/${app_name}.app")
#         message(STATUS "Processing ${app_name}.app")

#         # Handle osgPlugins directory
#         file(GLOB OSG_PLUGINS_DIR "${FULL_APP_PATH}/Contents/PlugIns/osgPlugins*")
#         if (EXISTS "${OSG_PLUGINS_DIR}")
#             file(RENAME "${OSG_PLUGINS_DIR}" "${FULL_APP_PATH}/Contents/PlugIns/osgPlugins")
#             execute_process(COMMAND "ln" "-s" "osgPlugins" "${OSG_PLUGINS_DIR}"
#                             WORKING_DIRECTORY "${FULL_APP_PATH}/Contents/PlugIns/")
#         endif()

#         # Skip signing if the option is enabled
#         if (NOT SKIP_SIGNING)
#             message(STATUS "Re-signing ${app_name}.app")
#             execute_process(COMMAND "codesign" "--force" "--deep" "-s" "-" "${FULL_APP_PATH}"
#                             RESULT_VARIABLE CODE_SIGN_RESULT)
#             if (CODE_SIGN_RESULT)
#                 message(FATAL_ERROR "Code signing failed for ${app_name}.app")
#             endif()
#         else()
#             message(STATUS "Skipping signing for ${app_name}.app")
#         endif()
#     endforeach(app_name)
# endif (APPLE)

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

    # Ensure the package directory is not busy before creating the disk image
    set(PACKAGE_DIR "/Users/runner/work/openmw/openmw/build/_CPack_Packages/Darwin/DragNDrop/OpenMW-0.49.0-Darwin/ALL_IN_ONE")
    set(DISK_IMAGE "/Users/runner/work/openmw/openmw/build/OpenMW-0.49.0-Darwin.dmg")

    # Check if the directory is busy
    execute_process(COMMAND lsof +D "${PACKAGE_DIR}" OUTPUT_VARIABLE DIR_BUSY)
    if (DIR_BUSY)
        message(STATUS "Waiting for the package directory to be free...")
        execute_process(COMMAND sleep 5)
        execute_process(COMMAND lsof +D "${PACKAGE_DIR}" OUTPUT_VARIABLE DIR_BUSY_AGAIN)
        if (DIR_BUSY_AGAIN)
            message(FATAL_ERROR "Package directory is still busy. Aborting.")
        endif()
    endif()

    # Create the disk image
    execute_process(COMMAND /usr/bin/hdiutil create -ov -srcfolder "${PACKAGE_DIR}"
                    -volname "OpenMW-0.49.0-Darwin" -fs "HFS+" -format UDZO "${DISK_IMAGE}"
                    RESULT_VARIABLE HDIUTIL_RESULT)
    if (HDIUTIL_RESULT)
        message(FATAL_ERROR "Disk image creation failed.")
    endif()
endif (APPLE)


# if (APPLE)
#     set(OPENMW_APP "OpenMW")
#     set(OPENMW_CS_APP "OpenMW-CS")

#     set(APPLICATIONS "${OPENMW_APP}" "${OPENMW_CS_APP}")
#     foreach(app_name IN LISTS APPLICATIONS)
#         set(FULL_APP_PATH "${CPACK_TEMPORARY_INSTALL_DIRECTORY}/ALL_IN_ONE/${app_name}.app")
#         message(STATUS "Re-signing ${app_name}.app")

#         # Handle osgPlugins directory
#         file(GLOB OSG_PLUGINS_DIR "${FULL_APP_PATH}/Contents/PlugIns/osgPlugins*")
#         if (EXISTS "${OSG_PLUGINS_DIR}")
#             file(RENAME "${OSG_PLUGINS_DIR}" "${FULL_APP_PATH}/Contents/PlugIns/osgPlugins")
#             execute_process(COMMAND "ln" "-s" "osgPlugins" "${OSG_PLUGINS_DIR}"
#                             WORKING_DIRECTORY "${FULL_APP_PATH}/Contents/PlugIns/")
#         endif()

#         # Code signing
#         execute_process(COMMAND "codesign" "--force" "--deep" "-s" "-" "${FULL_APP_PATH}"
#                         RESULT_VARIABLE CODE_SIGN_RESULT)
#         if (CODE_SIGN_RESULT)
#             message(FATAL_ERROR "Code signing failed for ${app_name}.app")
#         endif()
#     endforeach(app_name)
# endif (APPLE)