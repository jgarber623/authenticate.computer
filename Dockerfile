FROM ruby:2.7.3-alpine

ARG BUNDLER_VERSION="2.2.16"
ARG RAILS_VERSION=">= 6.1"

# Install system dependencies
RUN apk add --no-cache \
      g++ \
      make \
      nodejs \
      postgresql-client \
      postgresql-dev \
      tzdata \
      yarn

# Configure RubyGems and install Bundler and Rails
# See: https://devcenter.heroku.com/articles/bundler-version
RUN echo "gem: --no-document" >> ~/.gemrc && \
    gem install bundler --version "${BUNDLER_VERSION}" && \
    gem install rails --version "${RAILS_VERSION}"

# Create a dependencies cache folder for use as volume
RUN mkdir -p /usr/src/dependencies

# Configure Bundler and Yarn to use dependencies cache
RUN bundle config path /usr/src/dependencies/bundler && \
    yarn config set cache-folder /usr/src/dependencies/yarn

# Create a persistent volume for dependencies
VOLUME /usr/src/dependencies

WORKDIR /usr/src/app

EXPOSE 3000
