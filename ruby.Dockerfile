FROM ruby:2.5-alpine
MAINTAINER Carlos Nunez <dev@carlosnunez.me>
ARG ENVIRONMENT

RUN apk add --no-cache ruby-nokogiri ruby-dev build-base libxml2-dev libxslt-dev libffi-dev

COPY Gemfile /
RUN echo "Installing gems..." && bundle install --jobs=10 1>/dev/null
COPY . /app
WORKDIR /app

ENTRYPOINT ["ruby", "-e", "puts 'Welcome to your service.'"]
