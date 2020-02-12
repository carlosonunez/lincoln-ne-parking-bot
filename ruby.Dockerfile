FROM lambci/lambda:build-ruby2.5
MAINTAINER Carlos Nunez <dev@carlosnunez.me>
ARG ENVIRONMENT

RUN yum install -y ruby25-devel gcc libxml2 libxml2-devel \
  libxslt libxslt-devel patch curl

COPY Gemfile /
RUN bundle install
COPY . /app
WORKDIR /app

ENTRYPOINT ["ruby", "-e", "puts 'Welcome to your service.'"]
