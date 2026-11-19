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

| Konkurencja | RPS | p50 [ms] | p95 [ms] | p99 [ms] | Nieudane | Non-2xx |
|---|---|---|---|---|---|---|
| 10 | 66048.02 | 0 | 0 | 0 | 0 | 0 |
| 25 | 101595.04 | 0 | 0 | 1 | 0 | 0 |
| 50 | 102495.77 | 1 | 1 | 2 | 0 | 0 |
| 100 | 105407.40 | 0 | 2 | 5 | 0 | 0 |
| 200 | 81096.42 | 1 | 7 | 9 | 0 | 0 |
| 400 | 49213.81 | 3 | 18 | 21 | 0 | 0 |

Mediana liczona osobno dla każdej kolumny z trzech plików `wyniki-*.csv` (skrypt `mediany.sh`).

### RPS w poszczególnych przebiegach

| Konkurencja | Przebieg 1 (13:54:42) | Przebieg 2 (13:55:23) | Przebieg 3 (13:56:01) | Mediana |
|---|---|---|---|---|
| 10 | 66048.02 | 37756.51 | 82730.09 | 66048.02 |
| 25 | 69601.53 | 105346.33 | 101595.04 | 101595.04 |
| 50 | 68526.01 | 102495.77 | 119595.77 | 102495.77 |
| 100 | 89895.72 | 105407.40 | 116022.74 | 105407.40 |
| 200 | 70952.18 | 85528.57 | 81096.42 | 81096.42 |
| 400 | 41082.95 | 49213.81 | 49663.53 | 49213.81 |

## Środowisko

| Element | Wartość |
|---|---|
| Serwer WWW | nginx/1.18.0 (Ubuntu) |
| Generator obciążenia | ApacheBench 2.3 (`ab`) |
| System | WSL2, Ubuntu 22.04 |
| Rdzenie (`nproc`) | 8 |
| Pamięć RAM | 7.6 GiB (dostępne 6.8 GiB) |
| Swap | 2.0 GiB (nieużywany) |
| Testowany adres | `http://portfolio.local/` (statyczny `index.html`) |
| Parametry testu | 2000 żądań na poziom, keepalive (`ab -k`), rozgrzewka 500 żądań |
| Połączenie generator → serwer | ta sama maszyna, adres `eth0` WSL, bez fizycznej sieci |

## Komentarz

Generator (ab) i serwer (Nginx 1.18) działają na tej samej maszynie (WSL2, Ubuntu 22.04). Ruch idzie na adres eth0 WSL, a nie przez prawdziwą sieć. Generator zabiera procesor serwerowi, więc wyniki zaniżają możliwości serwera i nie testują sieci.

Jeden poziom trwa ok. 0,02–0,05 s, więc rozrzut między przebiegami jest duży (przy c=10 od 37,8 do 82,7 tys. RPS). Wyniki porównywać tylko jako mediany.
