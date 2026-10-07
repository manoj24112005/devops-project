FROM python:3.12-slim
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ .
# Version is baked in so /health shows which image is running
ARG APP_VERSION=dev
ENV APP_VERSION=$APP_VERSION
RUN useradd -m appuser
USER appuser
EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "main:app"]
