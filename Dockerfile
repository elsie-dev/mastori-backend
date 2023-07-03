# Build stage
FROM python:3.10-alpine as builder

WORKDIR /app

COPY requirements.txt .

RUN apk add --no-cache --virtual .build-deps postgresql-dev build-base \
    && python -m venv /env \
    && /env/bin/pip install --upgrade pip \
    && /env/bin/pip install --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.10-alpine

WORKDIR /app

COPY --from=builder /env /env
COPY . .

RUN apk add --no-cache $(scanelf --needed --nobanner --recursive /env \
        | awk -F': ' '{print $2}' \
        | sort -u \
        | xargs -r apk info --installed \
        | sort -u)

ENV VIRTUAL_ENV /env
ENV PATH /env/bin:$PATH

RUN chmod +x setup.sh

CMD ["sh", "setup.sh"]
