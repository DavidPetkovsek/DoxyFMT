/// @file main.cpp
/// @brief CLI entry point for the doxyfmt tool.
///
/// Argument parsing and mode dispatch (format / check / extract-snippets)
/// will be filled in once the core library has its parser and formatter.

#include "doxyfmt/comment_extractor.hpp"

#include <cstdio>
#include <span>
#include <string_view>

namespace {

constexpr std::string_view kVersion = "0.1.0";

auto print_usage() -> void
{
  std::puts(
    "doxyfmt — Doxygen-aware C++ comment formatter\n"
    "\n"
    "USAGE:\n"
    "  doxyfmt [--check] [--extract-snippets] <file>...\n"
    "  doxyfmt --version\n"
  );
}

}  // namespace

auto main(int argc, char** argv) -> int
{
  const std::span<char*> args{argv, static_cast<std::size_t>(argc)};

  if (args.size() < 2) {
    print_usage();
    return 1;
  }

  const std::string_view first{args[1]};
  if (first == "--version") {
    std::printf("doxyfmt %.*s\n",
                static_cast<int>(kVersion.size()), kVersion.data());
    return 0;
  }

  // Placeholder: real dispatch lands next iteration.
  print_usage();
  return 0;
}
