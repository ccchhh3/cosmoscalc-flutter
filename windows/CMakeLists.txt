cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

set(BINARY_NAME "cosmoscalc")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/run" CACHE PATH "" FORCE)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Profile" "Release")
endif()

# Apply a standard set of build settings that are configured in the
# temporary build directory. This can be removed for applications that
# need different build settings.
add_compile_definitions(UNICODE _UNICODE)

function(apply_standard_settings TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_link_options(${TARGET} PRIVATE /SUBSYSTEM:WINDOWS)
  target_compile_definitions(${TARGET} PRIVATE UNICODE _UNICODE)
  if(DEFINED MSVC_RUNTIME_LIBRARY)
    set_property(TARGET ${TARGET} PROPERTY
      MSVC_RUNTIME_LIBRARY "${MSVC_RUNTIME_LIBRARY}")
  endif()
endfunction()

# Flutter-level build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application-level build rules.
add_subdirectory("runner")

# Generated plugin build rules.
include(flutter/generated_plugins.cmake)

# === Installation ===
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}")
install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${CMAKE_INSTALL_PREFIX}" OPTIONAL)
install(FILES "${AOT_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}" OPTIONAL)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${CMAKE_INSTALL_PREFIX}"
    COMPONENT Runtime)
endif()

install(DIRECTORY "${FLUTTER_ASSET_DIR}" DESTINATION "${CMAKE_INSTALL_PREFIX}")
