/// @file comment_extractor.cpp
/// @brief Stub: real implementation lands in the next conversation.
///
/// The intent for this file is a raw-mode `clang::Lexer` over a `MemoryBuffer`
/// scanning for `tok::comment` tokens, then classifying each by its leading
/// characters. Coalescing of adjacent `///` lines happens here, not in the
/// parser, because the parser should see one logical comment block.

#include "doxyfmt/comment_extractor.hpp"

namespace doxyfmt {

auto extract_comments(
  std::string_view /*source*/,
  std::string_view /*virtual_path*/
) -> std::vector<CommentSpan>
{
  // TODO(next-iteration): drive clang::Lexer in raw mode and emit spans.
  return {};
}

}  // namespace doxyfmt
