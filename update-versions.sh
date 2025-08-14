#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq nix alejandra
# shellcheck shell=bash
set -euo pipefail

# Query supported targets
targets=$(nix eval --json --apply builtins.attrNames .#packages)

# Process index.json
echo "Fetching index.json" >&2
index=$(curl -L https://ziglang.org/download/index.json | jq -c --argjson targets "$targets" '
    with_entries(.value = (
        [
            {_date : .value.date, _version: .value.version // .key},
            ($targets[], "src") as $target | {
                ($target): .value[$target | sub("-darwin$"; "-macos")] // empty | {
                    filename: .tarball | capture("/(?<f>[^/]+)$").f,
                    shasum,
                },
            }
        ] | add
    ))
')

json2nix() {
    nix-instantiate --eval --arg-from-stdin json --expr '{json}: builtins.fromJSON json' | alejandra -q
}

# Generate new stable.nix
echo "Generating stable.nix" >&2
stable=$(jq -cr 'del(.master) | [.[]] | sort_by(._date)' <<<"$index" | json2nix)
echo "$stable" >versions/stable.nix

# Generate new nightly.nix
echo "Updating nightly.nix" >&2
nightly=$(nix eval --json --file ./versions/nightly.nix | jq -cr --argjson index "$index" '
    # Add latest nightly if it is newer than the current one
    if .[-1]._date != $index.master._date then
        . + [$index.master]
    end |
    # Check list is sorted
    if . != sort_by(._date) then
        error("Nightly versions are not sorted")
    end
' | json2nix)
echo "$nightly" >versions/nightly.nix

# Fetch community mirror list
echo "Fetching community mirror list" >&2
curl -Lo versions/community-mirrors.txt https://ziglang.org/download/community-mirrors.txt
