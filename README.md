# Lekcja 14 – testy wydajności serwera WWW

- `test_server.sh` – pomiar `ab` przy konkurencji 10–400, zapis do `wyniki-*.csv` i `surowe-*/`
- `generate_report.sh` – raport Markdown z jednego CSV
- `mediany.sh` – mediany z trzech przebiegów
- `pomiar.sh` – 3 przebiegi `test_server.sh` (50000 żądań) + mediany w podanym katalogu
- `raport.md` – punkt odniesienia (zadanie 1)
- `dziennik.md` + `strojenie/` – dziennik strojenia Nginksa (zadanie 4)

Powtórzenie pomiaru z zadania 1:

```bash
./test_server.sh http://portfolio.local/ 2000   # 3 razy
./mediany.sh wyniki-*.csv > mediany.csv
```

Pomiar do dziennika strojenia:

```bash
./pomiar.sh strojenie/<numer>-<nazwa-zmiany>
```
