#!/usr/bin/env bash
# install-llvm.sh — fetches and runs the official llvm.sh installer for
# the version doxyfmt builds against. Linux/Debian/Ubuntu only; macOS users
# should `brew install llvm@22` and Windows users should use winget.
#
# Idempotent: re-running is safe and just re-validates the install.
set -euo pipefail

REQUIRED_MAJOR=22

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This script is Linux-only. On macOS: brew install llvm@${REQUIRED_MAJOR}"
  exit 1
fi

if command -v "clang-${REQUIRED_MAJOR}" >/dev/null 2>&1; then
  installed_ver="$("clang-${REQUIRED_MAJOR}" --version | head -n1)"
  echo "clang-${REQUIRED_MAJOR} already installed: ${installed_ver}"
  exit 0
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

check_install_packages() {
	MISSING_PACKAGES=""

	set +e
	for PACKAGE_NAME in "$@"; do
		# check if the package is installed
		dpkg -s $PACKAGE_NAME &> /dev/null

		if [ $? -eq 0 ]; then
			echo "$PACKAGE_NAME is already installed."
		else
			MISSING_PACKAGES="$MISSING_PACKAGES $PACKAGE_NAME"
		fi
	done
	set -e

	if [ -z "$MISSING_PACKAGES" ]; then
        echo "All apt package dependencies are already installed."
    else
        echo "Installing missing packages: $MISSING_PACKAGES"
		sudo apt update
		sudo apt install -y $MISSING_PACKAGES
    fi
}

check_install_packages libzstd-dev libcurl4-openssl-dev libedit-dev

echo "Downloading llvm.sh ..."
curl -fsSL https://apt.llvm.org/llvm.sh -o "${tmpdir}/llvm.sh"
chmod +x "${tmpdir}/llvm.sh"

# `all` pulls headers, tools, and development packages we need for LibTooling.
sudo "${tmpdir}/llvm.sh" "${REQUIRED_MAJOR}" all

echo "Installed:"
"clang-${REQUIRED_MAJOR}" --version | head -n1
