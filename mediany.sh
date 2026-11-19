#!/bin/bash
# mediany.sh - mediana z dokładnie trzech plików CSV z test_server.sh
# Użycie: ./mediany.sh wyniki-*.csv
set -euo pipefail

echo "konkurencja,rps,p50_ms,p95_ms,p99_ms,nieudane,non2xx"
for c in 10 25 50 100 200 400; do
    wiersz="$c"
    for kol in 4 5 6 7 8 9; do
        wartosc=$(grep -h "^$c," "$@" | cut -d, -f"$kol" | sort -n | sed -n 2p)
        wiersz="$wiersz,$wartosc"
    done
    echo "$wiersz"
done
