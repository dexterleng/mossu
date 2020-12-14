FROM ruby:2.6.3

RUN mkdir -p /opt/app

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install nodejs
RUN apt-get install zip

WORKDIR /opt/app/mossu

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundler install

CMD rails s -b "0.0.0.0"