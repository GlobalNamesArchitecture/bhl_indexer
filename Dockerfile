FROM ubuntu:16.04
MAINTAINER Dmitry Mozzherin
ENV LAST_FULL_REBUILD 2017-08-15

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y ruby2.4 ruby2.4-dev locales \
    curl zlib1g-dev liblzma-dev libxml2-dev \
    libxslt-dev libmysqlclient-dev build-essential nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo 'gem: --no-rdoc --no-ri >> "$HOME/.gemrc"'

# Configure Bundler to install everything globally
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH

RUN gem install bundler && \
    bundle config --global path "$GEM_HOME" && \
    bundle config --global bin "$GEM_HOME/bin" && \
    mkdir /app

WORKDIR /app

ENV BUNDLE_APP_CONFIG $GEM_HOME

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install

COPY . /app
CMD bundle exec rackup
