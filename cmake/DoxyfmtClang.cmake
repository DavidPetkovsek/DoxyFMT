# DoxyfmtClang.cmake
#
# Locate Clang 22's LibTooling components. We deliberately avoid linking
# any of the heavy bits (Sema, AST, Tooling, Format) — raw lexing over a
# MemoryBuffer is all we need to identify comment tokens. The translation
# unit we format does not need to be parsable, let alone compilable.
#
# Discovery order (first hit wins):
#   1. DOXYFMT_CLANG_DIR  (user-provided absolute path to cmake/clang config)
#   2. LLVM_DIR + Clang_DIR (standard config-package vars)
#   3. /usr/lib/llvm-22/lib/cmake/{llvm,clang}  (apt.llvm.org via llvm.sh)
#   4. Homebrew prefix on macOS
#   5. find_package(Clang CONFIG REQUIRED) — falls back to CMAKE_PREFIX_PATH
#
# We require Clang 22 specifically to keep the LibTooling API surface stable.
# When upgrading, bump _doxyfmt_clang_required_major and re-validate against
# clang/Lex/Lexer.h API changes.

# 1 & 2: respect explicit user input as-is.
if(DEFINED DOXYFMT_CLANG_DIR)
  list(PREPEND CMAKE_PREFIX_PATH "${DOXYFMT_CLANG_DIR}")
endif()

# 3: standard llvm.sh install location on Debian/Ubuntu.
if(UNIX AND NOT APPLE AND EXISTS "/usr/lib/llvm-${_doxyfmt_clang_required_major}/lib/cmake/clang")
  list(APPEND CMAKE_PREFIX_PATH
    "/usr/lib/llvm-${_doxyfmt_clang_required_major}/lib/cmake/llvm"
    "/usr/lib/llvm-${_doxyfmt_clang_required_major}/lib/cmake/clang"
  )
endif()

# 4: Homebrew llvm@22 on macOS.
if(APPLE)
  execute_process(
    COMMAND brew --prefix llvm@${_doxyfmt_clang_required_major}
    OUTPUT_VARIABLE _brew_llvm_prefix
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  if(_brew_llvm_prefix AND EXISTS "${_brew_llvm_prefix}/lib/cmake/clang")
    list(APPEND CMAKE_PREFIX_PATH
      "${_brew_llvm_prefix}/lib/cmake/llvm"
      "${_brew_llvm_prefix}/lib/cmake/clang"
    )
  endif()
endif()

math(EXPR _doxyfmt_clang_required_next_major "${_doxyfmt_clang_required_major} + 1")
find_package(LLVM  ${_doxyfmt_clang_required_major}.${_doxyfmt_clang_required_minor}...<${_doxyfmt_clang_required_next_major} CONFIG REQUIRED)
find_package(Clang ${_doxyfmt_clang_required_major}.${_doxyfmt_clang_required_minor}...<${_doxyfmt_clang_required_next_major} CONFIG REQUIRED)

if(NOT LLVM_VERSION_MAJOR EQUAL _doxyfmt_clang_required_major)
  message(FATAL_ERROR
    "doxyfmt requires LLVM/Clang ${_doxyfmt_clang_required_major}.x, "
    "found ${LLVM_PACKAGE_VERSION}.\n"
    "Install via: bash scripts/install-llvm.sh"
  )
endif()

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION} at ${LLVM_DIR}")
message(STATUS "Found Clang             at ${Clang_DIR}")

# Aggregate the *minimum* Clang libs we link against into one INTERFACE
# target. If we ever need more (e.g. clangFrontend for CompilerInstance),
# add it here and nowhere else.
add_library(doxyfmt::clang_libtooling INTERFACE IMPORTED)
target_include_directories(doxyfmt::clang_libtooling SYSTEM INTERFACE
  ${LLVM_INCLUDE_DIRS}
  ${CLANG_INCLUDE_DIRS}
)
target_compile_definitions(doxyfmt::clang_libtooling INTERFACE
  ${LLVM_DEFINITIONS}
)
target_link_libraries(doxyfmt::clang_libtooling INTERFACE
  clangBasic
  clangLex
  LLVMSupport
)
