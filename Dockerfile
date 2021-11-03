FROM rust:1.54

WORKDIR /usr/src/mbtileserver

# # Compile + Cache dependencies 
# ADD Cargo.toml Cargo.toml
# ADD Cargo.lock Cargo.lock
# RUN mkdir src && \
#     echo "fn main() { }" > src/main.rs && \
#     cargo build --release

COPY . .

RUN mkdir /tiles
COPY ../germany.mbtiles /tiles/germany.mbtiles

RUN cargo install --path .

CMD ["mbtileserver"]