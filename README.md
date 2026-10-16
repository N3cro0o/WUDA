# Repozytorium projektu CI/CD WUDA

## Zadanie 1

Celem tego etapu jest stworzenie potoku CI/CD do tworzenia obrazów dockerowych i udostępnienia ich do [insert name here]. Dodatkowo, należy zakutalizować i zmienić kod aby mógł być godny mianowania kodem *na produkcję*

W tym celu wykorzystano najnowszą wersję [Django](https://www.djangoproject.com/) wraz z [Uvicornem](https://uvicorn.dev/)

### Todo

* ~Przygotować środowisko i zaktualizować niezbędne technologie.~
  1. ~Czytaj przygotować req.txt~
* Przygotować dockerfile i docker-compose z postgresikiem.
  * Napisać potok github actions do tworzenia i udostępniania obrazu.
* Przygotować kod na produkcje
  1. Przygotować .env
  2. Zaktualizować pliki pod Uvicorn
  3. Przygotować połączenie ze słoniem

## Odpalanie dev

```
python3 -m venv .venv
.venv/Scripts/activate
```
W zależności czy bash, cmd, powershell czy inny chłam, opdalasz inny plik.
Następnym krokiem jest uruchomienie bazy danych posrgres. W tym celu przygotowano docker-compose.yml. W przyszłości ten plik będzie obsługiwał inicjalizację wszystkiego kekw.
Potem:

```
python3 manage.py migrate
python3 manage.py runserver
```
