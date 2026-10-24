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
  1. ~Przygotować .env~
  2. ~Zaktualizować pliki pod Uvicorn~
  3. ~Przygotować połączenie ze słoniem~

## Konfiguracja (.env)

Skopiuj `.env.template` do `.env` i uzupełnij wartości. Plik `.env` jest w `.gitignore` i nie trafia do repo.

| Zmienna | Opis |
|---|---|
| `DJANGO_SECRET_KEY` | Tajny klucz Django, wymagany. Każdy generuje własny (polecenie niżej). |
| `DJANGO_DEBUG` | `True` = tryb deweloperski. `False` lub brak = tryb produkcyjny. |
| `DJANGO_ALLOWED_HOSTS` | Adresy strony oddzielone przecinkami, np. `example.com,www.example.com`. Przy `DJANGO_DEBUG=True` można zostawić puste (Django dopuszcza wtedy `localhost`). |
| `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` | Dane bazy. Docker Compose tworzy z nich bazę przy **pierwszym** uruchomieniu, późniejsza zmiana w `.env` nie zmienia istniejącej bazy. |
| `POSTGRES_HOST`, `POSTGRES_PORT` | Adres bazy, domyślnie `localhost` i `5432`. |

Generowanie klucza (po zainstalowaniu bibliotek):

```
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

## Odpalanie dev

W `.env` ustaw `DJANGO_DEBUG=True`. Puste lub brak oznacza tryb produkcyjny, w którym `runserver` nie wystartuje bez `DJANGO_ALLOWED_HOSTS`.

```
python3 -m venv .venv
.venv/Scripts/activate
pip install -r req-dev.txt
docker compose up -d
python manage.py migrate
python manage.py runserver
```

Plik aktywacyjny zależy od powłoki: `.venv\Scripts\activate.bat` (cmd), `.venv\Scripts\Activate.ps1` (PowerShell), `.venv/Scripts/activate` (Git Bash), `.venv/bin/activate` (Linux). Po aktywacji `.venv` używaj `python` (na Windowsie w `.venv` nie ma `python3`).

## Odpalanie prod

Bez narzędzi deweloperskich: bez `runserver` i bez pylinta.

W `.env`: `DJANGO_DEBUG=False`, `DJANGO_ALLOWED_HOSTS` z adresem strony i osobny `DJANGO_SECRET_KEY`.

```
pip install -r req.txt
python manage.py migrate
python manage.py collectstatic --noinput
python -m uvicorn mysite.asgi:application --host 0.0.0.0 --port 8000 --workers 2
```
