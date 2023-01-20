
export PATH="$PATH:/opt/homebrew/bin"
if which swiftlint > /dev/null; then
  swiftlint lint --strict | sed 's/warning: /error: /g'
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
