# DoxyfmtWarnings.cmake
#
# Single source of truth for warning flags. Targets that opt into our
# strict baseline link against doxyfmt::warnings (PRIVATE). Anything
# linking PUBLIC against it would propagate the flags to consumers,
# which we don't want.

add_library(doxyfmt_warnings INTERFACE)
add_library(doxyfmt::warnings ALIAS doxyfmt_warnings)

if(MSVC)
  target_compile_options(doxyfmt_warnings INTERFACE
    /W4 /permissive- /Zc:preprocessor /Zc:__cplusplus
    /wd4068        # unknown pragma — LLVM headers use clang-specific ones
  )
  if(DOXYFMT_WERROR)
    target_compile_options(doxyfmt_warnings INTERFACE /WX)
  endif()
else()
  target_compile_options(doxyfmt_warnings INTERFACE
    -Wall -Wextra -Wpedantic
    -Wshadow -Wnon-virtual-dtor -Wcast-align
    -Wunused -Woverloaded-virtual -Wconversion -Wsign-conversion
    -Wnull-dereference -Wdouble-promotion -Wformat=2
    -Wimplicit-fallthrough
  )
  if(DOXYFMT_WERROR)
    target_compile_options(doxyfmt_warnings INTERFACE -Werror)
  endif()
endif()
