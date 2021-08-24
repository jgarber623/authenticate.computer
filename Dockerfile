FROM ruby:2.7.4-alpine

ARG BUNDLER_VERSION="2.2.26"
ARG RAILS_VERSION=">= 6.1"
ARG REDIS_VERSION="6.0.12"

# Install system dependencies
RUN apk add --update --no-cache \
      g++ \
      git \
      make \
      nodejs \
      postgresql-client \
      postgresql-dev \
      tzdata \
      yarn && \
    rm -rf /var/cache/apk/*

# Install redis-cli the hard way
RUN cd /tmp && \
    wget -O redis.tar.gz "https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz" && \
    tar -xvzf redis.tar.gz && \
    make -C "redis-${REDIS_VERSION}" install redis-cli /usr/local/bin && \
    rm -rf redis.tar.gz "redis-${REDIS_VERSION}"

# Configure Git to avoid "hints" when using bundler-audit
RUN git config --global pull.rebase true

# Configure RubyGems and install Bundler and Rails
# See: https://devcenter.heroku.com/articles/bundler-version
RUN echo "gem: --no-document" >> ~/.gemrc && \
    gem install bundler --version "${BUNDLER_VERSION}" && \
    gem install rails --version "${RAILS_VERSION}"

# Create a dependencies cache folder for use as volume
RUN mkdir -p /usr/src/dependencies

# Configure Bundler and Yarn to use dependencies cache
RUN bundle config set jobs 10 && \
    bundle config set retries 5 && \
    bundle config set path /usr/src/dependencies/bundler && \
    yarn config set cache-folder /usr/src/dependencies/yarn

# Pre-install Rails and its dependent gems
RUN cd /usr/src/dependencies && \
    rails new empty-rails-app --force --database=postgresql --skip-bundle --skip-webpack-install && \
    cd empty-rails-app && \
    bundle update

# Create a persistent volume for dependencies
VOLUME /usr/src/dependencies

WORKDIR /usr/src/app

EXPOSE 3000
