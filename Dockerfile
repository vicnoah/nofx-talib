# ═══════════════════════════════════════════════════════════════
# TA-Lib Standalone Build Image
# Pre-compiled TA-Lib for reuse across builds
# ═══════════════════════════════════════════════════════════════

ARG ALPINE_VERSION=3.20
ARG TA_LIB_VERSION=0.4.0

# ──────────────────────────────────────────────────────────────
# Build TA-Lib from source
# ──────────────────────────────────────────────────────────────
FROM alpine:${ALPINE_VERSION} AS builder
ARG TA_LIB_VERSION

RUN apk update && apk add --no-cache \
    wget tar make gcc g++ musl-dev autoconf automake

RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-${TA_LIB_VERSION}-src.tar.gz && \
    tar -xzf ta-lib-${TA_LIB_VERSION}-src.tar.gz && \
    cd ta-lib && \
    if [ "$(uname -m)" = "aarch64" ]; then \
        CONFIG_GUESS=$(find /usr/share -name config.guess | head -1) && \
        CONFIG_SUB=$(find /usr/share -name config.sub | head -1) && \
        cp "$CONFIG_GUESS" config.guess && \
        cp "$CONFIG_SUB" config.sub && \
        chmod +x config.guess config.sub; \
    fi && \
    ./configure --prefix=/usr/local && \
    make && make install && \
    cd .. && rm -rf ta-lib ta-lib-${TA_LIB_VERSION}-src.tar.gz

# ──────────────────────────────────────────────────────────────
# Minimal runtime image with TA-Lib installed to /usr/local
# ──────────────────────────────────────────────────────────────
FROM alpine:${ALPINE_VERSION}
COPY --from=builder /usr/local /usr/local
