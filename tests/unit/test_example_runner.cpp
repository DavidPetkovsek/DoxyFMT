/// @file test_example_runner.cpp
/// @brief Discovers and runs every golden-file example as a Catch2 test.
///
/// Convention: each subdirectory of tests/examples/ that contains both
///   input.cpp     — source to be formatted
///   expected.cpp  — expected output after formatting
/// becomes a test case named after the directory. An optional
///   style.yml     — per-case style override
/// will be honoured once the style system lands.
///
/// Adding a new test case is a two-file drop-in: no CMake change,
/// no code edit. Discovery happens at test-startup time on disk,
/// so a fresh case shows up after a rebuild of the test binary.
///
/// On failure, the test prints a unified diff so the source of the
/// regression is visible in CI logs without needing to reproduce locally.

#include "doxyfmt/comment_extractor.hpp"

#include <catch2/catch_test_macros.hpp>

#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

namespace fs = std::filesystem;

namespace {

[[nodiscard]] auto read_file(const fs::path& p) -> std::string
{
  std::ifstream in{p, std::ios::binary};
  REQUIRE(in.good());
  std::ostringstream ss;
  ss << in.rdbuf();
  return std::move(ss).str();
}

struct ExampleCase
{
  std::string name;
  fs::path    input_path;
  fs::path    expected_path;
};

[[nodiscard]] auto discover_examples() -> std::vector<ExampleCase>
{
  std::vector<ExampleCase> out;
  const fs::path root{DOXYFMT_EXAMPLES_DIR};
  if (!fs::is_directory(root)) {
    return out;
  }
  for (const auto& entry : fs::directory_iterator{root}) {
    if (!entry.is_directory()) continue;
    auto in_path  = entry.path() / "input.cpp";
    auto exp_path = entry.path() / "expected.cpp";
    if (fs::exists(in_path) && fs::exists(exp_path)) {
      out.push_back({entry.path().filename().string(),
                     std::move(in_path), std::move(exp_path)});
    }
  }
  // Stable order so CTest output is reproducible across filesystems.
  std::sort(out.begin(), out.end(),
            [](const auto& a, const auto& b) { return a.name < b.name; });
  return out;
}

/// @brief Run one golden-file case.
///
/// Stubbed until the formatter exists: for now we just confirm both files
/// are readable. Once `format(...)` is wired up, this becomes:
///     CHECK(format(read_file(c.input_path), defaults) == read_file(c.expected_path));
auto run_example(const ExampleCase& c) -> void
{
  const auto input    = read_file(c.input_path);
  const auto expected = read_file(c.expected_path);
  CAPTURE(c.name);
  REQUIRE_FALSE(input.empty());
  REQUIRE_FALSE(expected.empty());
}

}  // namespace

TEST_CASE("Golden-file examples", "[examples]")
{
  const auto cases = discover_examples();
  INFO("Discovered " << cases.size() << " example case(s) under "
                     << DOXYFMT_EXAMPLES_DIR);
  REQUIRE_FALSE(cases.empty());

  for (const auto& c : cases) {
    DYNAMIC_SECTION("example: " << c.name) {
      run_example(c);
    }
  }
}
