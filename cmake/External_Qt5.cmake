
set(Qt510 "1")
# Qt 5.x is going to be used.
if(Qt510)
  set(qt5_version_major "5.10")
  set(qt5_version_full "5.10.0")
  set(qt5_version_short "5.10.0")
  # This variable is used inside the javascript file that performs the Qt installation
  set(qt5_installer_version "qt5.5100")
else()
  set(qt5_version_major "5.9")
  set(qt5_version_full "5.9.3")
  set(qt5_version_short "5.9.3")
  # This variable is used inside the javascript file that performs the Qt installation
  set(qt5_installer_version "593")
endif()

set(extProjectName "Qt${qt5_version_full}")
message(STATUS "External Project: ${extProjectName}" )



set(qt5_INSTALL "${DREAM3D_SDK}/${extProjectName}${qt5_version_full}")
set(qt5_BINARY_DIR "${DREAM3D_SDK}/superbuild/${extProjectName}/Build")

get_filename_component(_self_dir ${CMAKE_CURRENT_LIST_FILE} PATH)

set(QT_INSTALL_LOCATION "${DREAM3D_SDK}/${extProjectName}")

if(APPLE)
  set(qt5_Headless_FILE "Qt_HeadlessInstall_OSX.js")
elseif(WIN32)
  set(qt5_Headless_FILE "Qt_HeadlessInstall_Win64.js")
else()
  set(qt5_Headless_FILE "Qt_HeadlessInstall_OSX.js")
endif()

set(QT_MSVC_VERSION_NAME "")
if(MSVC13)
   set(QT_MSVC_VERSION_NAME "msvc2013_64")
endif()
if(MSVC14)
  set(QT_MSVC_VERSION_NAME "msvc2015_64")
endif()
if(MSVC_VERSION GREATER 1900)
  set(QT_MSVC_VERSION_NAME "msvc2017_64")
endif()

set(JSFILE "${DREAM3D_SDK}/superbuild/${extProjectName}/Download/Qt_HeadlessInstall.js")
configure_file(
  "${_self_dir}/${qt5_Headless_FILE}"
  "${JSFILE}"
  @ONLY
)

if(APPLE)
  set(qt5_url "http://qt.mirror.constant.com/archive/qt/${qt5_version_major}/${qt5_version_short}/qt-opensource-mac-x64-${qt5_version_full}.dmg")

  set(Qt5_OSX_BASE_NAME qt-opensource-mac-x64-${qt5_version_full})

  set(Qt5_OSX_DMG_ABS_PATH "${DREAM3D_SDK}/superbuild/${extProjectName}/${Qt5_OSX_BASE_NAME}.dmg")
  set(Qt5_DMG ${Qt5_OSX_DMG_ABS_PATH})

  configure_file(
    "${_self_dir}/Qt5_osx_install.sh.in"
    "${CMAKE_BINARY_DIR}/Qt5_osx_install.sh"
    @ONLY
  )


  if(NOT EXISTS "${Qt5_DMG}")
    message(STATUS "===============================================================")
    message(STATUS "    Downloading ${extProjectName}${qt5_version_full} Offline Installer")
    message(STATUS "    ${qt5_url}")
    message(STATUS "    Large Download!! This can take a bit... Please be patient")
    file(DOWNLOAD ${qt5_url} "${Qt5_DMG}" SHOW_PROGRESS)
  endif()


  if(NOT EXISTS "${QT_INSTALL_LOCATION}/${qt5_version_short}/clang_64/bin/qmake")
    message(STATUS "    Running Qt5 Installer. A GUI Application will pop up on your machine.")
    message(STATUS "    This may take some time for the installer to start.")
    message(STATUS "    Please wait for the installer to finish.")
    execute_process(COMMAND "${CMAKE_BINARY_DIR}/Qt5_osx_install.sh"
                    OUTPUT_FILE "${DREAM3D_SDK}/superbuild/${extProjectName}/Download/Qt5-offline-out.log"
                    ERROR_FILE "${DREAM3D_SDK}/superbuild/${extProjectName}/Download/Qt5-offline-err.log"
                    ERROR_VARIABLE mount_error
                    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )

  endif()
  set(QMAKE_EXECUTABLE ${QT_INSTALL_LOCATION}/${qt5_version_short}/clang_64/bin/qmake)

elseif(WIN32)
  set(qt5_online_installer "qt-opensource-windows-x86-${qt5_version_full}.exe")
  set(qt5_url "http://qt.mirror.constant.com/archive/qt/${qt5_version_major}/${qt5_version_short}/qt-opensource-windows-x86-${qt5_version_full}.exe")

  if(NOT EXISTS "${DREAM3D_SDK}/superbuild/${extProjectName}/Download/${qt5_online_installer}")
    message(STATUS "===============================================================")
    message(STATUS "   Downloading ${extProjectName}")
    message(STATUS "   Large Download!! This can take a bit... Please be patient")
    file(DOWNLOAD ${qt5_url} "${DREAM3D_SDK}/superbuild/${extProjectName}/Download/${qt5_online_installer}" SHOW_PROGRESS)
  endif()

  set(QT5_ONLINE_INSTALLER "${DREAM3D_SDK}/superbuild/${extProjectName}/Download/${qt5_online_installer}")
  configure_file(
    "${_self_dir}/Qt_HeadlessInstall.bat"
    "${DREAM3D_SDK}/superbuild/${extProjectName}/Download/Qt_HeadlessInstall.bat"
    @ONLY
  )

  if(NOT EXISTS "${DREAM3D_SDK}/${extProjectName}")
    message(STATUS "Executing the Qt5 Installer... ")
    execute_process(COMMAND "${DREAM3D_SDK}/superbuild/${extProjectName}/Download/Qt_HeadlessInstall.bat"
                    OUTPUT_FILE "${DREAM3D_SDK}/superbuild/${extProjectName}/Download/qt-unified-out.log"
                    ERROR_FILE "${DREAM3D_SDK}/superbuild/${extProjectName}/Download/qt-unified-err.log"
                    ERROR_VARIABLE installer_error
                    WORKING_DIRECTORY ${qt5_BINARY_DIR} )
  endif()
  set(QMAKE_EXECUTABLE ${QT_INSTALL_LOCATION}/${qt5_version_short}/${QT_MSVC_VERSION_NAME}/bin/qmake.exe)
else()
  
  set(QMAKE_EXECUTABLE ${QT_INSTALL_LOCATION}/${qt5_version_short}/gcc_64/bin/qmake)
endif()


ExternalProject_Add(Qt5

  TMP_DIR "${DREAM3D_SDK}/superbuild/${extProjectName}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${DREAM3D_SDK}/superbuild/${extProjectName}/Stamp/${CMAKE_BUILD_TYPE}"
  DOWNLOAD_DIR "${DREAM3D_SDK}/superbuild/${extProjectName}/Download"
  SOURCE_DIR "${DREAM3D_SDK}/superbuild/${extProjectName}/Source"
  BINARY_DIR "${DREAM3D_SDK}/superbuild/${extProjectName}/Build"
  INSTALL_DIR "${DREAM3D_SDK}/superbuild/${extProjectName}/Install"

  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  TEST_COMMAND ""
  )

#-- Append this information to the DREAM3D_SDK CMake file that helps other developers
#-- configure DREAM3D for building
FILE(APPEND ${DREAM3D_SDK_FILE} "\n")
FILE(APPEND ${DREAM3D_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
FILE(APPEND ${DREAM3D_SDK_FILE} "# Qt ${qt5_version_full} Library\n")
if(APPLE)
  FILE(APPEND ${DREAM3D_SDK_FILE} "set(Qt5_DIR \"\${DREAM3D_SDK_ROOT}/${extProjectName}/${qt5_version_short}/clang_64/lib/cmake/Qt5\" CACHE PATH \"\")\n")
elseif(WIN32)
  FILE(APPEND ${DREAM3D_SDK_FILE} "set(Qt5_DIR \"\${DREAM3D_SDK_ROOT}/${extProjectName}/${qt5_version_short}/${QT_MSVC_VERSION_NAME}/lib/cmake/Qt5\" CACHE PATH \"\")\n")
else()
  FILE(APPEND ${DREAM3D_SDK_FILE} "set(Qt5_DIR \"\${DREAM3D_SDK_ROOT}/${extProjectName}/${qt5_version_short}/gcc_64/lib/cmake/Qt5\" CACHE PATH \"\")\n")
endif()
FILE(APPEND ${DREAM3D_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${Qt5_DIR})\n")


