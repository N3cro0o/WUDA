FROM python:3.12-alpine
WORKDIR /wuda
RUN apk add --no-cache gcc musl-dev linux-headers
COPY req.txt .
RUN pip install -r req.txt
COPY . .
RUN DJANGO_SECRET_KEY=lorem POSTGRES_DB=ipsum POSTGRES_USER=dolor POSTGRES_PASSWORD=sit python manage.py collectstatic --noinput
EXPOSE 8000
CMD ["python",  "-m",  "uvicorn",  "mysite.asgi:application",  "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
