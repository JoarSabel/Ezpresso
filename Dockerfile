FROM elixir:latest AS build

WORKDIR /app

RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools && \
    # might add nodejs here
    mix local.hex --force && \
    mix local.rebar --force

COPY . .

RUN mix deps.get
RUN mix compile

CMD mix deps.get && mix phx.server
