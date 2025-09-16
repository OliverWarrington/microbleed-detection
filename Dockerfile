# ─────────────────────────────
# Stage 1: Dependency builder
# ─────────────────────────────
FROM ghcr.io/astral-sh/uv:python3.11-bookworm AS deps
WORKDIR /app

# Copy only dependency metadata first
COPY pyproject.toml README.md ./

# Create venv and install ONLY dependencies
# This layer will be cached unless pyproject.toml changes
ENV VIRTUAL_ENV=/opt/venv
RUN --mount=type=cache,target=/root/.cache/uv \
    uv venv /opt/venv \
    && uv pip install --no-cache-dir .

# ─────────────────────────────
# Stage 2: Package builder
# ─────────────────────────────
FROM deps AS build
WORKDIR /app

# Copy the actual source code
COPY microbleednet ./microbleednet

# Install your package into the venv
RUN uv pip install --no-cache-dir .

# ─────────────────────────────
# Stage 3: Runtime image
# ─────────────────────────────
FROM python:3.11-slim-bookworm AS runtime
WORKDIR /app

# Copy the venv from build stage
COPY --from=build /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONOPTIMIZE=1
ENV MICROBLEEDNET_PRETRAINED_MODEL_PATH="/tmp/data/models"

# Run your CLI entrypoint
ENTRYPOINT [ "microbleednet" ]
CMD [ "microbleednet" ]

