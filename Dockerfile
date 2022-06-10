FROM bitwalker/alpine-elixir:1.11.4 as release

WORKDIR /app

RUN apk update && apk add bash

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

COPY config/ /app/config/
COPY mix.exs /app/
COPY mix.* /app/

ENV SECRET_KEY_BASE "${SECRET_KEY_BASE}"

COPY . /app/

ENV MIX_ENV=prod
RUN mix do deps.get --only $MIX_ENV, deps.compile

WORKDIR /app
RUN MIX_ENV=prod mix release

########################################################################

FROM bitwalker/alpine-elixir:1.11.4

RUN apk update && apk add bash

ENV MIX_ENV=prod \
    SHELL=/bin/bash

RUN apk add --update openssl ncurses-libs postgresql-client && \
    rm -rf /var/cache/apk/*

WORKDIR /app
COPY --from=release /app/_build/prod/rel/zoop_gateway .
COPY --from=release /app/bin ./bin

CMD ["./bin/start.sh"]
