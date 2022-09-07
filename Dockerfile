ARG MIX_ENV="prod"
ARG DATABASE_URL="postgresql://root@roach1:26257/chirp_cockroach_dev?sslmode=disable"
ARG SECRET_KEY_BASE="X7f9dcyrqW2LBuvIxgqh6Oo27K+E7wIpugTv8IENfTM9y3TnCp99AoprFXDcQKwS"
ARG PHX_SERVER=true
FROM elixir:1.14.0-alpine as build
# RUN apk add --no-cache build-base git python3 curl

RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

ARG MIX_ENV
ARG DATABASE_URL
ARG SECRET_KEY_BASE
ARG PHX_SERVER
ENV MIX_ENV="${MIX_ENV}"
ENV DATABASE_URL="${DATABASE_URL}"
ENV SECRET_KEY_BASE="${SECRET_KEY_BASE}"
ENV PHX_SERVER="${PHX_SERVER}"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# copy compile configuration files
RUN mkdir config
COPY config/config.exs config/$MIX_ENV.exs config/

# compile dependencies
RUN mix deps.compile

# copy assets
COPY priv priv
COPY assets assets

# Compile assets
RUN mix assets.deploy

# compile project
COPY lib lib
RUN mix compile

# copy runtime configuration file
COPY config/runtime.exs config/

# assemble release
RUN mix release

# # app stage
FROM alpine:3.16 AS app

ARG MIX_ENV
ARG DATABASE_URL
ARG SECRET_KEY_BASE
ARG PHX_SERVER
ENV MIX_ENV="${MIX_ENV}"
ENV DATABASE_URL="${DATABASE_URL}"
ENV SECRET_KEY_BASE="${SECRET_KEY_BASE}"
ENV PHX_SERVER="${PHX_SERVER}"

# # install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs

ENV USER="elixir"

WORKDIR "/home/${USER}/app"

# # Create  unprivileged user to run the release
RUN \
  addgroup \
  -g 1000 \
  -S "${USER}" \
  && adduser \
  -s /bin/sh \
  -u 1000 \
  -G "${USER}" \
  -h "/home/${USER}" \
  -D "${USER}" \
  && su "${USER}"

# # run as user
USER "${USER}"

# # copy release executables
COPY --from=build --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/chirp_cockroach ./

ENTRYPOINT ["bin/chirp_cockroach"]

CMD ["start"]
