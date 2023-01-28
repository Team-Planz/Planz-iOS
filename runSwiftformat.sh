
export PATH="$PATH:/opt/homebrew/bin"
if which swiftformat >/dev/null; then
  swiftformat . --disable trailingCommas
else
  echo "warning: SwiftFormat not installed, download from https://github.com/nicklockwood/SwiftFormat"
fi
