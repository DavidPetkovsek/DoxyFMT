# doxyfmt_core: the engine. Static, internal, not installed.
# Splitting this from the CLI is what makes tests link directly against
# the parser/formatter without dragging in CLI argument parsing.

add_library(doxyfmt_core STATIC
  comment_extractor.cpp
  # parser.cpp        # added in next iteration
  # formatter.cpp     # added in next iteration
  # style.cpp         # added in next iteration
)
add_library(doxyfmt::core ALIAS doxyfmt_core)

target_include_directories(doxyfmt_core
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set_target_properties(doxyfmt_core PROPERTIES
  CXX_EXTENSIONS OFF
  POSITION_INDEPENDENT_CODE ON   # static lib may end up linked into a shared one later
)

target_link_libraries(doxyfmt_core
  PUBLIC
    doxyfmt::clang_libtooling     # exposed via headers (SourceLocation, etc.)
  PRIVATE
    doxyfmt::warnings
    doxyfmt::sanitizers
)
