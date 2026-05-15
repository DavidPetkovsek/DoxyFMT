/// @file comment_extractor.hpp
/// @brief Identifies Doxygen comment ranges in a translation unit.
///
/// The extractor uses Clang's raw lexer (no preprocessor, no AST) to walk
/// the input buffer and return spans corresponding to `///` and `/**` style
/// comments only. Plain `//` and `/*` comments are intentionally skipped:
/// they are not Doxygen-meaningful and we don't want to touch them.

#pragma once

#include <cstddef>
#include <string_view>
#include <vector>

namespace doxyfmt {

/// @brief A Doxygen comment as it appears in source.
///
/// Byte offsets are into the original buffer the extractor was given.
/// `end_offset` is one-past-the-last byte (half-open range). The `kind`
/// determines how the parser will strip comment markers.
struct CommentSpan
{
  enum class Kind : unsigned char
  {
    LineTriple,   ///< `///` block (one or more consecutive `///` lines)
    BlockDouble,  ///< `/** ... */`
  };

  std::size_t begin_offset = 0;
  std::size_t end_offset   = 0;
  Kind        kind         = Kind::LineTriple;
};

/// @brief Extract all Doxygen comment spans from a buffer.
///
/// @param source       The full source text; not retained.
/// @param virtual_path A path used only for diagnostics. Need not exist.
/// @return Spans in source order, never overlapping.
///
/// Adjacent `///` lines are coalesced into a single LineTriple span so that
/// downstream parsing sees one logical comment block instead of N tokens.
[[nodiscard]] auto extract_comments(
  std::string_view source,
  std::string_view virtual_path = "<input>"
) -> std::vector<CommentSpan>;

}  // namespace doxyfmt
