#!/usr/bin/env bash
# checker.sh のテスト
#
# curl をスタブに差し替えるため、ネットワークなしで実行できる。
# GNU date が必要（DATE 環境変数で指定、既定は gdate）。
#   DATE=gdate bash tests/test_checker.sh

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECKER="$ROOT/checker.sh"
DATE_CMD="${DATE:-gdate}"

PASS=0
FAIL=0

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# curl スタブ: URL のパターンに応じて curl -v 相当の出力を stderr に書く
mkdir -p "$WORK/bin"
cat > "$WORK/bin/curl" <<'EOF'
#!/usr/bin/env bash
url="${@: -1}"
case "$url" in
  *ssl-problem*)
    echo "* SSL certificate problem: certificate has expired" >&2
    ;;
  *no-ssl*)
    echo "* Connected to host" >&2
    ;;
  *)
    echo "* Server certificate:" >&2
    echo "*  expire date: Dec 31 23:59:59 2030 GMT" >&2
    ;;
esac
EOF
chmod +x "$WORK/bin/curl"

export PATH="$WORK/bin:$PATH"
export DATE="$DATE_CMD"

pass() {
  PASS=$((PASS + 1))
  echo "  ok   - $1"
}

fail() {
  FAIL=$((FAIL + 1))
  echo "  FAIL - $1"
  echo "         expected: $2"
  echo "         actual:   $3"
}

# assert_eq <説明> <期待値> <実際の値>
assert_eq() {
  if [ "$2" = "$3" ]; then
    pass "$1"
  else
    fail "$1" "$2" "$3"
  fi
}

# assert_match <説明> <正規表現> <実際の値>
assert_match() {
  if printf '%s\n' "$3" | grep -Eq "$2"; then
    pass "$1"
  else
    fail "$1" "match /$2/" "$3"
  fi
}

# GNU date が無ければテストできない
if ! "$DATE_CMD" --version >/dev/null 2>&1; then
  echo "GNU date not found (DATE=$DATE_CMD). Set DATE=gdate or similar." >&2
  exit 2
fi

echo "== usage"
out=$(bash "$CHECKER" 2>&1); rc=$?
assert_eq "no arguments prints usage" "1" "$rc"
assert_match "no arguments message" "^Usage:" "$out"

out=$(bash "$CHECKER" -h 2>&1); rc=$?
assert_eq "-h exits with 1" "1" "$rc"

echo "== -u (single URL)"
out=$(bash "$CHECKER" -u https://ok.example/ 2>&1); rc=$?
assert_eq "valid cert exits 0" "0" "$rc"
assert_match "valid cert prints days,url,date" \
  "^[0-9]{3,},https://ok\.example/,[[:space:]]*Dec 31 23:59:59 2030 GMT$" "$out"

out=$(bash "$CHECKER" -u https://no-ssl.example/ 2>&1); rc=$?
assert_eq "no SSL info exits 0" "0" "$rc"
assert_eq "no SSL output" "000,https://no-ssl.example/, NO SSL" "$out"

out=$(bash "$CHECKER" -u https://ssl-problem.example/ 2>&1); rc=$?
assert_eq "SSL problem exits 0" "0" "$rc"
assert_match "SSL problem output" \
  "^000,https://ssl-problem\.example/,[[:space:]]+certificate has expired$" "$out"

echo "== -f (file)"
FILE="$WORK/hosts.txt"
cat > "$FILE" <<'EOF'
# コメント行は無視される

https://ok.example/ # 行末コメント
https://ok.example/with-space   # 空白付きコメント
https://no-ssl.example/
EOF
out=$(bash "$CHECKER" -f "$FILE" 2>&1); rc=$?
assert_eq "file mode exits 0" "0" "$rc"
assert_eq "file mode line count (comments and blanks skipped)" "3" "$(printf '%s\n' "$out" | wc -l | tr -d ' ')"
assert_match "trailing comment and spaces are stripped from URL" \
  "^[0-9]{3,},https://ok\.example/," "$(printf '%s\n' "$out" | head -n 1)"
assert_match "URL with spaces before comment is trimmed" \
  "^[0-9]{3,},https://ok\.example/with-space," "$(printf '%s\n' "$out" | sed -n 2p)"
assert_eq "no-SSL line in file mode" "000,https://no-ssl.example/, NO SSL" "$(printf '%s\n' "$out" | sed -n 3p)"

echo "== special characters are preserved"
FILE2="$WORK/special.txt"
printf '%s\n' 'https://ok.example/a%20b' 'https://ok.example/x\y' > "$FILE2"
out=$(bash "$CHECKER" -f "$FILE2" 2>&1)
assert_match "percent sign is printed literally" \
  "https://ok\.example/a%20b," "$(printf '%s\n' "$out" | sed -n 1p)"
assert_match "backslash is kept" \
  'https://ok\.example/x\\y,' "$(printf '%s\n' "$out" | sed -n 2p)"

echo "== GNU date check"
out=$(DATE=definitely-not-a-command bash "$CHECKER" -u https://ok.example/ 2>&1); rc=$?
assert_eq "missing date command exits 99" "99" "$rc"
assert_match "missing date command message" "Not using GNU date" "$out"

echo
echo "passed: $PASS, failed: $FAIL"
[ "$FAIL" -eq 0 ]
