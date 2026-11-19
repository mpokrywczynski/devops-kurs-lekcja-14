# Raport z testu wydajności serwera WWW

- **Data wykonania**: 2026-11-19 14:00:07
- **Maszyna testowa**: DESKTOP-KFID43G, 8 rdzeni, 7.6Gi RAM
- **Plik danych**: `wyniki-20261119-135442.csv`
- **Kryterium zaliczenia**: p95 poniżej 400 ms przy zerowej liczbie błędów

## Wyniki pomiarów

| Konkurencja | RPS | p50 [ms] | p95 [ms] | p99 [ms] | Błędy | Ocena |
|---|---|---|---|---|---|---|
| 10 | 66048.0 | 0 | 0 | 0 | 0 | zaliczony |
| 25 | 69601.5 | 0 | 1 | 1 | 0 | zaliczony |
| 50 | 68526.0 | 1 | 2 | 2 | 0 | zaliczony |
| 100 | 89895.7 | 0 | 2 | 6 | 0 | zaliczony |
| 200 | 70952.2 | 2 | 7 | 9 | 0 | zaliczony |
| 400 | 41082.9 | 4 | 20 | 23 | 0 | zaliczony |

## Wnioski automatyczne

- Maksymalna zmierzona przepustowość: **89895.7 RPS** przy konkurencji 100.
- Najwyższa konkurencja spełniająca kryterium (p95 < 400 ms, 0 błędów): **400**.
- W całym zakresie testu nie wystąpił ani jeden błąd.
- Przepustowość przy najwyższej konkurencji spadła o 54% względem maksimum - system jest za punktem załamania.

## Zalecenia

1. Za pojemność operacyjną przyjmij konkurencję o jeden poziom niższą od najwyższej zaliczonej.
2. Powtórz pomiar trzykrotnie i porównaj mediany, zanim uznasz wynik za wiążący.
3. Przed zmianą konfiguracji zapisz obecne wartości jako punkt odniesienia (baseline).

## Mediany z trzech przebiegów

konkurencja  rps        p50_ms  p95_ms  p99_ms  nieudane  non2xx
10           66048.02   0       0       0       0         0
25           101595.04  0       0       1       0         0
50           102495.77  1       1       2       0         0
100          105407.40  0       2       5       0         0
200          81096.42   1       7       9       0         0
400          49213.81   3       18      21      0         0

## Środowisko

nginx version: nginx/1.18.0 (Ubuntu)
This is ApacheBench, Version 2.3
8
               total        used        free      shared  buff/cache   available
Mem:           7.6Gi       555Mi       5.5Gi       3.0Mi       1.6Gi       6.8Gi
Swap:          2.0Gi          0B       2.0Gi

## Komentarz

Generator (ab) i serwer (Nginx 1.18) działają na tej samej maszynie (WSL2, Ubuntu 22.04). Ruch idzie na adres eth0 WSL, a nie przez prawdziwą sieć. Generator zabiera procesor serwerowi, więc wyniki zaniżają możliwości serwera i nie testują sieci.
