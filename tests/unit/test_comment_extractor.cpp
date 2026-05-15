/// @file test_comment_extractor.cpp
/// @brief Unit tests for the comment extractor's invariants.
///
/// These are tight, surgical tests — one behaviour per TEST_CASE. They
/// complement the golden-file tests (test_example_runner.cpp), which
/// cover end-to-end formatting on realistic inputs.

#include "doxyfmt/comment_extractor.hpp"

#include <catch2/catch_test_macros.hpp>

#include <string_view>

using namespace std::string_view_literals;

TEST_CASE("extract_comments on empty input returns no spans",
          "[extractor][edge]")
{
  const auto spans = doxyfmt::extract_comments(""sv);
  REQUIRE(spans.empty());
}

TEST_CASE("extract_comments ignores non-Doxygen comments",
          "[extractor]")
{
  // `//` and `/*` are plain C++ comments and must not appear as Doxygen
  // spans. Only `///` and `/**` count.
  constexpr auto src =
    "int x = 0; // plain line comment\n"
    "/* plain block */\n"
    "int y = 1;\n"sv;

  const auto spans = doxyfmt::extract_comments(src);
  CHECK(spans.empty());
}

// More cases land alongside the parser/formatter implementation.
// The skeleton's job is to prove the wiring: header visible, lib linked,
// Catch2 discovered, ctest reports the case.
