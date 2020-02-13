FROM ruby:2.5-alpine
MAINTAINER Carlos Nunez <dev@carlosnunez.me>
ARG ENVIRONMENT

RUN apk add --no-cache ruby-nokogiri ruby-dev build-base libxml2-dev libxslt-dev libffi-dev

COPY Gemfile /
RUN bundle install --jobs=10
COPY . /app
WORKDIR /app

ENTRYPOINT ["ruby", "-e", "puts 'Welcome to your service.'"]
