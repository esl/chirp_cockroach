ARG ELIXIR_VERSION=1.14.0
ARG OTP_VERSION=25.0.4
ARG ALPINE_VERSION=3.16.2

ARG BUILDER_IMAGE="elixir:1.14.0-alpine"
ARG RUNNER_IMAGE="alpine:3.16.2"

ARG DATABASE_URL
ARG SECRET_KEY_BASE
ARG PHX_SERVER
ARG MIX_ENV

FROM ${BUILDER_IMAGE} as builder

# prepare build dir
WORKDIR /app
ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force
# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}
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

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/chirp_cockroach ./

USER nobody

CMD ["./app/bin/chirp_cockroach", "start"]
