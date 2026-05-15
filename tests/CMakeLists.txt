# ---------------------------------------------------------------------------
# Catch2 v3 via FetchContent. Pinned by tag for reproducibility.
# ---------------------------------------------------------------------------
include(FetchContent)
FetchContent_Declare(
  Catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG        v3.5.4
  GIT_SHALLOW    TRUE
  SYSTEM                          # silences warnings from Catch2 headers
)

set(CATCH_INSTALL_DOCS    OFF CACHE BOOL "" FORCE)
set(CATCH_INSTALL_EXTRAS  OFF CACHE BOOL "" FORCE)
set(CATCH_BUILD_TESTING   OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(Catch2)
list(APPEND CMAKE_MODULE_PATH "${catch2_SOURCE_DIR}/extras")
include(Catch)

# ---------------------------------------------------------------------------
# Unit-test binary
# ---------------------------------------------------------------------------
add_executable(doxyfmt_unit_tests
  unit/test_comment_extractor.cpp
  unit/test_example_runner.cpp     # drives golden-file cases
)

target_link_libraries(doxyfmt_unit_tests
  PRIVATE
    doxyfmt::core
    doxyfmt::warnings
    doxyfmt::sanitizers
    Catch2::Catch2WithMain
)

# Path to the examples directory, baked in so the runner can find it
# regardless of where CTest is invoked from.
target_compile_definitions(doxyfmt_unit_tests PRIVATE
  DOXYFMT_EXAMPLES_DIR="${CMAKE_CURRENT_SOURCE_DIR}/examples"
)

# Catch2's auto-discovery: each TEST_CASE becomes its own CTest test,
# which means each golden-file example shows up as a separate row in
# CTest output. Failures are precise.
catch_discover_tests(doxyfmt_unit_tests
  REPORTER       console
  OUTPUT_ON_FAILURE
)
