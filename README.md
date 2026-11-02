# Repozytorium projektu CI/CD WUDA

## Zadanie 1

Celem tego etapu jest stworzenie potoku CI/CD do tworzenia obrazów dockerowych i udostępnienia ich do GitHub Container Registry. Dodatkowo, należy zaktualizować i zmienić kod aby mógł być godny mianowania kodem *na produkcję*

W tym celu wykorzystano najnowszą wersję [Django](https://www.djangoproject.com/) wraz z [Uvicornem](https://uvicorn.dev/)

### Zmiany

W ramach prac nad projektem zaktualizowano wersję Django do wersji 6.1.2 i dodano niezbędne technologie pozwalające na uruchomienie serwisu. Zmodyfikowano kod aplikacji poprzez dodanie pliku `asgi.py` pozwalającego technologii Uvicorn do stworzenia serwera. Dodatkowo dodano pakiet WhiteNoise, który kompresuje i serwuje pliki statyczne, ponieważ ani Uvicorn, ani Django w trybie produkcyjnym nie robią tego same.

W celu izolacji bazy danych i wprowadzenia możliwości jej skalowania usunięto połączenie z bazą SQLite3 i zastąpiono połączeniem z PostgreSQL. Jedynym wyjątkiem, gdzie połączenie to nie zostało zmienione są testy aplikacji Django. Ponieważ w trakcie testów sprawdzane nie jest połączenie ale działanie samej aplikacji, wykorzystanie lokalnej bazy SQLite spełniało wymogi postawione w ramach testów.

### Opis potoku CI/CD

W katalogu .github/workflows/ dodano dwa pliki opisujące potoki GitHub Actions. Plik pylint.yml odpowiedzialny jest za sprawdzenie zasad semantycznych w dwóch przypadkach. Sprawdzane i oceniane są liczby błędów oraz liczby ostrzeżeń. Jeżeli ocena jest gorsza niż 8.0, program zwraca kod błędu i potok jest przerywany. Następnie sprawdzana jest zgodność stylistyczna. Jeżeli ocena jest gorsza niż 7.0, potok jest przerywany. Po zakończeniu testów programu pylint wysyłany jest event o skończeniu prac. Plik build-container.yml odpowiedzialny jest za przeprowadzenie testów oraz za przygotowanie obrazu aplikacji. Ten potok nasłuchuje na event końca pracy testów lintera i jeżeli wynik jest pozytywny, rozpoczyna testy aplikacji Django. Tak jak wcześniej opisano, testy przeprowadzane są wykorzystując połączenie z lokalną bazą SQLite3. Po pozytywnym przeprowadzeniu testów potok rozpoczyna budowę obrazu aplikacji Django. Po zalogowaniu, ekstrakcji metadanych i przygotowaniu pliku obrazu, potok wykorzystuje pakiet docker/build-push-action do udostępnienia pliku w wybranym repozytorium. W tym przypadku plik udostępniany jest w GitHub Container Registry wykorzystując nazwę repozytorium i obrazu. Po zakończonej pracy potok generuje raport i kończy pracę.

## Konfiguracja (.env)

Skopiuj `.env.template` do `.env` i uzupełnij wartości. Plik `.env` jest w `.gitignore` i w `.dockerignore`.

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

## Budowanie aplikacji lokalnie

### Odpalanie dev

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

### Odpalanie prod

Bez narzędzi deweloperskich: bez `runserver` i bez pylinta.

W `.env`: `DJANGO_DEBUG=False`, `DJANGO_ALLOWED_HOSTS` z adresem strony i osobny `DJANGO_SECRET_KEY`.

```
pip install -r req.txt
python manage.py migrate
python manage.py collectstatic --noinput
python -m uvicorn mysite.asgi:application --host 0.0.0.0 --port 8000 --workers 2
```

## Wykorzystanie docker-compose

W ramach prac przygotowano plik docker-compose.yml. Aby uruchomić system należy wpisać następującą komendę:

```
docker compose up -d 
```

W celu uruchomienia systemu budując lokalny obraz należy w konfiguracji obrazu `django` wpisać polecenie `build: .`. Program wykorzysta lokalny plik Dockerfile aby zbudować obraz po czym zostanie uruchomiony razem z systemem bazodanowym PostgreSQL. Aby wykorzystać obraz znajdujący się w repozytorium GitHub, należy zamienić polecenie build na polecenie `image: ghcr.io/n3cro0o/wuda:master`. Plik obrazu zostanie pobrany ze zdalnego serwera, po czym zostanie uruchomiony.
