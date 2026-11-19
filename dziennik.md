# Dziennik strojenia – portfolio.local

- **Serwer:** nginx/1.18.0 (Ubuntu 22.04, WSL2, 8 rdzeni), statyczny `index.html`
- **Pomiar:** `./pomiar.sh` = 3× `test_server.sh http://portfolio.local/ 50000` (ab -k), potem mediany (`mediany.sh`)
- **Porównanie:** mediany przy konkurencji **c=100**; cztery metryki: RPS, p95, p99, odsetek błędów
- **Zasada:** jedna zmiana na wpis; „po” z jednego wpisu jest „przed” dla następnego
- **Szum:** jeśli mediana „po” mieści się w rozrzucie trzech przebiegów „przed”, to nie jest poprawa
- **Dowód zmiany:** `diff` zrzutów `sudo nginx -T` przed i po każdej zmianie
- **Dane:** `strojenie/0-baseline`, `1-worker-connections`, `2-keepalive-requests`, `3-access-log-buffer`

## Zmiana 1: worker_connections 768 → 4096

**Co zmieniono:** w `/etc/nginx/nginx.conf`, blok `events`: `worker_connections 768;` → `worker_connections 4096;`

**Dlaczego:** podniesienie limitu jednoczesnych połączeń na proces roboczy (sufit = `worker_processes × worker_connections`).

| Metryka (c=100) | Przed (0-baseline) | Po (1-worker-connections) |
|---|---|---|
| RPS | 139373.21 | 136485.23 |
| p95 [ms] | 2 | 2 |
| p99 [ms] | 2 | 2 |
| Błędy [%] | 0 | 0 |

Rozrzut RPS (3 przebiegi): przed 81837 – 146029, po 24844 – 139409.

**Wniosek:** zmiana nie przyniosła poprawy. Różnica RPS (-2%) mieści się w rozrzucie, opóźnienia i błędy bez zmian. Test dochodzi najwyżej do 400 jednoczesnych połączeń, więc stary limit 768 nie był wąskim gardłem – podniesiony został sufit, którego test nie dotykał. Zmiana ma sens dopiero przy ruchu powyżej ~768 połączeń na proces.

Uwaga: planowane razem z tą zmianą `LimitNOFILE=65535` nie zadziałało – w `/proc/<pid>/limits` procesu roboczego nadal jest `Max open files 1024`. Nie wpłynęło to na wynik (400 połączeń < 1024 deskryptory), ale przy ruchu powyżej ~1000 połączeń limit deskryptorów zablokowałby nowe `worker_connections`.

## Zmiana 2: keepalive_requests 100 → 1000

**Co zmieniono:** w `/etc/nginx/nginx.conf`, blok `http`: dopisane `keepalive_requests 1000;` (w Nginx 1.18 domyślnie 100; od 1.19.10 domyślnie 1000).

**Dlaczego:** po 100 żądaniach na jednym połączeniu keepalive Nginx je zamyka i klient musi nawiązać nowe połączenie TCP. Wyższy limit = mniej nowych połączeń.

| Metryka (c=100) | Przed (1-worker-connections) | Po (2-keepalive-requests) |
|---|---|---|
| RPS | 136485.23 | 140850.23 |
| p95 [ms] | 2 | 2 |
| p99 [ms] | 2 | 2 |
| Błędy [%] | 0 | 0 |

Rozrzut RPS (3 przebiegi): przed 24844 – 139409, po 105692 – 143672.

**Wniosek:** zmiana nie przyniosła poprawy. Wzrost RPS o 3% mieści się w rozrzucie, p95 i p99 bez zmian. Generator i serwer są na tej samej maszynie, więc nowe połączenie TCP przez lokalny interfejs kosztuje bardzo mało – zamykanie połączenia co 100 żądań nie było tu problemem. Większy efekt byłby przy prawdziwej sieci, gdzie każde nowe połączenie to dodatkowe opóźnienie (RTT).

## Zmiana 3: bufor zapisu access_log

**Co zmieniono:** w `/etc/nginx/sites-available/portfolio.local`:
`access_log /var/log/nginx/portfolio.access.log;` → `access_log /var/log/nginx/portfolio.access.log combined buffer=64k flush=5s;`

**Dlaczego:** bez bufora każde żądanie to osobny zapis do pliku logu (wywołanie systemowe). Z buforem Nginx zbiera wpisy i zapisuje je paczkami po 64 KB albo co 5 s.

| Metryka (c=100) | Przed (2-keepalive-requests) | Po (3-access-log-buffer) |
|---|---|---|
| RPS | 140850.23 | 174375.21 |
| p95 [ms] | 2 | 1 |
| p99 [ms] | 2 | 2 |
| Błędy [%] | 0 | 0 |

Rozrzut RPS (3 przebiegi): przed 105692 – 143672, po 171969 – 177432.

**Wniosek:** zmiana przyniosła poprawę. RPS wzrósł o ok. 24%, a najsłabszy przebieg „po” (171969) jest wyższy od najlepszego „przed” (143672) – to nie jest szum. Poprawa widoczna też przy innych poziomach (c=200: 52544 → 168172, c=400: 127365 → 161151), p95 spadło z 2 do 1 ms. Przy statycznej stronie, którą Nginx serwuje z pamięci podręcznej systemu, zapis logu był dużą częścią pracy na żądanie.

Koszt: wpisy pojawiają się w logu z opóźnieniem do 5 s (gorzej przy `tail -f` w trakcie diagnozy), a przy awarii serwera można stracić ostatnie niezapisane wpisy.

## Podsumowanie

| Zmiana | RPS c=100 (mediana) | Efekt |
|---|---|---|
| 0. Punkt odniesienia | 139373 | – |
| 1. worker_connections 4096 | 136485 | brak poprawy (szum) |
| 2. keepalive_requests 1000 | 140850 | brak poprawy (szum) |
| 3. access_log buffer=64k | 174375 | poprawa ok. 24% |

Jedyną zmianą z mierzalnym efektem w tym środowisku było buforowanie logu. Dwie pierwsze podnoszą limity, do których test nie dochodził – są przygotowaniem na większy ruch, a nie przyspieszeniem.
