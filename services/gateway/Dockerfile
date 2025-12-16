FROM python:3.11-slim

# 1. basic OS deps -------------------------------------------------------------
RUN apt-get update && apt-get install -y gcc && rm -rf /var/lib/apt/lists/*

# 2. create non-root user (safer) ---------------------------------------------
ENV APP_USER=appuser
RUN useradd -m ${APP_USER}
WORKDIR /home/${APP_USER}

# 3. install Python libs -------------------------------------------------------
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. copy source ---------------------------------------------------------------
COPY app ./app
COPY .env.dev .env.dev

USER ${APP_USER}
EXPOSE 80
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]