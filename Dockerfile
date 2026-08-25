FROM hexpm/elixir:1.17.3-erlang-27.2-debian-bookworm-20241016-slim AS builder
WORKDIR /app
COPY mix.exs ./
COPY lib ./lib
RUN MIX_ENV=prod mix compile --warnings-as-errors

FROM debian:bookworm-slim
RUN useradd --system --uid 10001 --create-home appuser
WORKDIR /app
COPY --from=builder /usr/local /usr/local
COPY --from=builder /app /app
USER 10001
CMD ["elixir", "-e", "IO.puts(\"sky-saml-lab ready\")"]
