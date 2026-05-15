cmake_minimum_required(VERSION 3.25)

set(_doxyfmt_clang_required_major 22)
set(CMAKE_C_COMPILER "clang-${_doxyfmt_clang_required_major}")
set(CMAKE_CXX_COMPILER "clang++-${_doxyfmt_clang_required_major}")
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

project(doxyfmt
  VERSION 0.1.0
  DESCRIPTION "Doxygen-aware comment formatter and extractor for C++"
  LANGUAGES CXX C
)

# Validate Clang version is correct and find _doxyfmt_clang_required_minor
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  if(CMAKE_CXX_COMPILER_VERSION MATCHES "^${_doxyfmt_clang_required_major}\\.([0-9]+)")
    set(_doxyfmt_clang_required_minor ${CMAKE_MATCH_1})
  else()
    message(STATUS "^${_doxyfmt_clang_required_major}\\.(\\d+)")
    message(FATAL_ERROR "Incorrect Clang version: ${CMAKE_CXX_COMPILER_VERSION}")
  endif()
else()
  message(FATAL_ERROR "Must be compiled with Clang not ${CMAKE_CXX_COMPILER_ID}")
endif()


# ---------------------------------------------------------------------------
# Project-wide options
# ---------------------------------------------------------------------------
option(DOXYFMT_BUILD_TESTS  "Build the test suite"            ON)
option(DOXYFMT_WERROR       "Treat warnings as errors"        OFF)
option(DOXYFMT_ENABLE_ASAN  "Enable AddressSanitizer (Debug)" OFF)
option(DOXYFMT_ENABLE_UBSAN "Enable UBSanitizer (Debug)"      OFF)

# Compile-commands DB for clangd / clang-tidy / our own tooling.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "" FORCE)

# Default to Release if nothing else is specified.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release RelWithDebInfo)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(DoxyfmtWarnings)        # compile_flags interface target
include(DoxyfmtSanitizers)      # sanitizer interface target
include(DoxyfmtClang)           # locates Clang 22 LibTooling

# ---------------------------------------------------------------------------
# Targets
# ---------------------------------------------------------------------------
add_subdirectory(src)           # doxyfmt_core (STATIC, internal)
add_subdirectory(app)           # doxyfmt (executable, installed)

if(DOXYFMT_BUILD_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif()

# ---------------------------------------------------------------------------
# Install: ONLY the CLI binary (per project decision)
# ---------------------------------------------------------------------------
include(GNUInstallDirs)
install(TARGETS doxyfmt
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  COMPONENT Runtime
)

# Friendly summary at the end of configure.
message(STATUS "")
message(STATUS "doxyfmt ${PROJECT_VERSION} configured")
message(STATUS "  Build type   : ${CMAKE_BUILD_TYPE}")
message(STATUS "  C++ standard : ${CMAKE_CXX_STANDARD} (target-set to 23)")
message(STATUS "  Tests        : ${DOXYFMT_BUILD_TESTS}")
message(STATUS "  Clang version: ${LLVM_PACKAGE_VERSION}")
message(STATUS "")
