# doxyfmt

Doxygen-aware C++ comment formatter and snippet extractor, built on Clang 22's LibTooling.

## What this is

`clang-format` understands C++ syntax but treats Doxygen comments as opaque text. `doxyfmt` fills that gap: it parses `///` and `/**` blocks, enforces tag ordering (`@brief` before `@details` before `@param` before `@return`...), aligns parameter columns, normalises blank lines between sections, and extracts code snippets for CI verification. Plain `//` and `/*` comments are left untouched.

`doxyfmt` and `clang-format` are designed to compose: run one then the other; the pipeline is idempotent.

## Building

```bash
# Linux: one-time setup
bash scripts/install-llvm.sh # installs clang-22 + dev headers via apt.llvm.org, and libcurl, libedit, and libzstd which are clang-22 dependencies

# Configure & build
cmake --preset default
cmake --build --preset default

# Test
ctest --preset default --output-on-failure

# Install (CLI binary only)
cmake --install build
```

macOS: `brew install llvm@22` instead of the script. Windows: winget LLVM 22.

## Layout

```
doxyfmt/
├── CMakeLists.txt              # top-level
├── cmake/                      # CMake modules (Clang lookup, warnings, sanitizers)
├── include/doxyfmt/            # public headers for doxyfmt_core
├── src/                        # doxyfmt_core implementation (STATIC, in-tree only)
├── app/                        # doxyfmt CLI (the installed binary)
├── tests/
│   ├── unit/                   # tight Catch2 unit tests
│   └── examples/               # golden-file cases: <name>/input.cpp + expected.cpp
└── scripts/                    # llvm.sh wrapper, dev helpers
```

### Why the core is its own target

`doxyfmt_core` is a static library; `doxyfmt` (the binary) and `doxyfmt_unit_tests` both link against it. This means tests exercise the same API consumers would, and the CLI stays a thin wrapper around the parser, formatter, and snippet extractor.

It's deliberately *not* installed: only the binary is. If `find_package(doxyfmt)` ever becomes a requirement, the core graduates to an exported target without disturbing callers.

### Why Clang LibTooling

Comment identification is harder than it looks — raw strings (`R"(...)"`), line splices (`\\\n`), comments inside macro definitions, and weird BOMs all conspire to break hand-rolled scanners. We use Clang's `Lexer` in raw mode (no preprocessing, no AST), which means we get correct tokenization for free and the input doesn't need to be compilable. We link against `clangBasic`, `clangLex`, and `LLVMSupport` — nothing more.

## Adding a golden-file test

Drop two files under `tests/examples/<descriptive_name>/`:

- `input.cpp` — the source to format
- `expected.cpp` — what `doxyfmt` should produce

Rebuild the test binary and `ctest` will pick the case up automatically. Failures show up as a discrete `examples/<name>` row in CTest output.

## Project decisions log

| Decision                | Choice                                      | Reason                                |
|-------------------------|---------------------------------------------|---------------------------------------|
| Comment identification  | Clang LibTooling raw lexer                  | Handles edge cases that bite scanners |
| LLVM acquisition        | `apt.llvm.org` via `llvm.sh` (script only)  | Avoids dragging LLVM through vcpkg    |
| Test framework          | Catch2 v3, `FetchContent`                   | No system dependency, pinned by tag   |
| Install scope           | CLI binary only                             | Library is in-tree for now            |
| C++ standard            | C++23                                       | Matches consumer codebase             |
```
