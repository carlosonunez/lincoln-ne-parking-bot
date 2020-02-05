FROM lambci/lambda:build-ruby2.5
MAINTAINER Carlos Nunez <dev@carlosnunez.me>
ARG ENVIRONMENT
ENV BROWSER_URL=https://github.com/carlosonunez/poltergeist-lambda/raw/1.0.0/phantomjs_lambda.zip

RUN yum install -y ruby25-devel gcc libxml2 libxml2-devel \
  libxslt libxslt-devel patch curl

RUN curl -L -o /phantomjs_lambda.zip "$BROWSER_URL"
RUN unzip /phantomjs_lambda.zip -d /opt && rm /phantomjs_lambda.zip
WORKDIR /var/task

ENTRYPOINT ["ruby", "-e", "puts 'Welcome to your service.'"]
