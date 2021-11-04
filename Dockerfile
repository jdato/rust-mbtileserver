FROM rust:1.54 AS rust_builder

WORKDIR /app

# Compile + Cache dependencies 
ADD Cargo.toml Cargo.toml
ADD Cargo.lock Cargo.lock
RUN mkdir src && \
    echo "fn main() { }" > src/main.rs && \
    cargo build --release

COPY src src
COPY templates templates

RUN cargo build --release

FROM debian:bullseye-slim

RUN apt update
RUN apt install libsqlite3-dev -y

COPY --from=rust_builder /app/target/release/mbtileserver mbtileserver

RUN mkdir /tiles
COPY germany.mbtiles /tiles/germany.mbtiles

CMD ["./mbtileserver", "-d", "/tiles"]