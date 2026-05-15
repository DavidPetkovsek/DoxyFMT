# DoxyfmtSanitizers.cmake
#
# Optional ASan/UBSan, gated by cache options. Applies only to Debug-style
# builds where the runtime cost is acceptable. Targets opt in by linking
# doxyfmt::sanitizers PRIVATE.

add_library(doxyfmt_sanitizers INTERFACE)
add_library(doxyfmt::sanitizers ALIAS doxyfmt_sanitizers)

set(_san_flags "")
if(DOXYFMT_ENABLE_ASAN)
  list(APPEND _san_flags -fsanitize=address -fno-omit-frame-pointer)
endif()
if(DOXYFMT_ENABLE_UBSAN)
  list(APPEND _san_flags -fsanitize=undefined -fno-sanitize-recover=undefined)
endif()

if(_san_flags AND NOT MSVC)
  target_compile_options(doxyfmt_sanitizers INTERFACE ${_san_flags})
  target_link_options   (doxyfmt_sanitizers INTERFACE ${_san_flags})
endif()
