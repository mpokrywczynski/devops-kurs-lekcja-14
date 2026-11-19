#!/bin/bash
# pomiar.sh - 3 przebiegi test_server.sh + mediany w podanym katalogu
# Użycie: ./pomiar.sh strojenie/0-baseline
set -euo pipefail

mkdir -p "$1"
cd "$1"
for i in 1 2 3; do
    ../../test_server.sh http://portfolio.local/ 50000
done
../../mediany.sh wyniki-*.csv > mediany.csv
column -s, -t mediany.csv
