#!/bin/bash
# Static checks of the code in this repository:
#   - ShellCheck for the shell scripts   (fails on warnings and errors)
#   - Bandit     for the Python programs (fails on medium and high severity)
#   - Pyflakes   for the Python programs (report only, never fails)
# It fails only on findings that are NOT listed, with a reason, in
# .github/code-checks-allow.txt. GitHub Actions runs it on Debian 13 with the
# tools from the Debian archive (.github/workflows/code-checks.yml). To run it
# on your own Debian, from the repository root:
#   sudo apt install shellcheck bandit pyflakes3
#   bash .github/code-checks.sh
# These tools only find some kinds of mistakes. A clean run is not a security
# audit.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
ALLOW=.github/code-checks-allow.txt

# Which files to check: tracked files, by extension or by their first line (#!).
sh_files=()
py_files=()
while IFS= read -r -d '' f; do
    if [ ! -f "$f" ] || [ -L "$f" ]; then continue; fi
    case "$f" in
        *.sh) sh_files+=("$f"); continue ;;
        *.py) py_files+=("$f"); continue ;;
    esac
    first=""
    IFS= read -r first < "$f" || true
    if [[ $first =~ ^\#!.*python ]]; then
        py_files+=("$f")
    elif [[ $first =~ ^\#!.*(/|[[:space:]])(ba|da)?sh([[:space:]]|$) ]]; then
        sh_files+=("$f")
    fi
done < <(git ls-files -z)
echo "Checking ${#sh_files[@]} shell scripts and ${#py_files[@]} Python programs."

# Every finding becomes one line: "file:CODE<TAB>full message".
found=$(mktemp)
trap 'rm -f "$found"' EXIT
if [ ${#sh_files[@]} -gt 0 ]; then
    { shellcheck --version | sed -n 2p; } >&2
    shellcheck -S warning -f gcc "${sh_files[@]}" 2>&1 \
        | sed -nE 's/^([^:]+):[0-9]+:[0-9]+: [a-z]+: .*\[(SC[0-9]+)\]$/\1:\2\t&/p' >> "$found" || true
fi
if [ ${#py_files[@]} -gt 0 ]; then
    { bandit --version | head -1; } >&2
    bandit -q -ll -f custom --msg-template '{relpath}:{test_id}	{relpath}:{line}: {severity}: {msg} [{test_id}]' \
        "${py_files[@]}" 2>/dev/null | grep -E '^[^[:space:]]+:B[0-9]+	' >> "$found" || true
fi

# Compare with the list of known and explained findings.
allowed=$(sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$ALLOW")
new=$(awk -F'\t' 'NR==FNR { ok[$1]=1; next } !($1 in ok) { print $2 }' <(printf '%s\n' "$allowed") "$found")
stale=$(awk -F'\t' 'NR==FNR { seen[$1]=1; next } !($0 in seen) { print }' "$found" <(printf '%s\n' "$allowed"))

echo
echo "Known findings (listed in $ALLOW): $(cut -f1 "$found" | grep -cxFf <(printf '%s\n' "$allowed") || true)"
if [ -n "$stale" ]; then
    echo "Listed in $ALLOW but no longer found (the line can be removed):"
    printf '%s\n' "$stale" | sed 's/^/  /'
fi

if [ ${#py_files[@]} -gt 0 ]; then
    echo
    echo "pyflakes (report only):"
    if command -v pyflakes3 >/dev/null; then pyflakes3 "${py_files[@]}" || true
    else python3 -m pyflakes "${py_files[@]}" || true; fi
fi

echo
if [ -n "$new" ]; then
    echo "NEW findings:"
    printf '%s\n' "$new"
    exit 1
fi
echo "No new findings."
