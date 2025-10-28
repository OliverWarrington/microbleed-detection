FROM ghcr.io/astral-sh/uv:python3.11-bookworm AS deps
WORKDIR /app

COPY requirements.txt pyproject.toml README.md ./

RUN uv venv \
    && uv pip install --no-cache-dir .

COPY src ./
RUN uv pip install --no-cache-dir .

ENV MICROBLEEDNET_PRETRAINED_MODEL_PATH="/models"
ENTRYPOINT [ "uv", "run", "microbleednet" ]

