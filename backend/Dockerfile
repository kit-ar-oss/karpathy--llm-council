FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# System deps (kept minimal for uvicorn[standard])
RUN pip install --no-cache-dir \
      fastapi>=0.115.0 \
      "uvicorn[standard]>=0.32.0" \
      python-dotenv>=1.0.0 \
      httpx>=0.27.0 \
      pydantic>=2.9.0

COPY backend ./backend
COPY pyproject.toml ./pyproject.toml

RUN mkdir -p /app/data/conversations

EXPOSE 8001

CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8001"]
