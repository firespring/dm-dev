ARG USER=dm-dev
FROM ruby:2.7.8-slim-bullseye
MAINTAINER Firespring "info.dev@firespring.com"

WORKDIR /usr/src

RUN apt-get update \
    && apt-get install -y build-essential curl default-libmysqlclient-dev vim gpg \
   gawk autoconf automake bison libgdbm-dev libncurses5-dev libsqlite3-dev libtool \
   pkg-config sqlite3 libreadline-dev libssl-dev iputils-ping libxml2-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

SHELL ["/bin/bash", "-l", "-c"]
RUN groupadd rvm
RUN useradd --create-home --shell /bin/bash --no-log-init -G rvm,sudo daryn.warriner

USER daryn.warriner
WORKDIR /home/daryn.warriner

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
    && \curl -sSL https://get.rvm.io | bash -s stable

## copy in the dm-dev repo
WORKDIR /home/daryn.warriner/datamapper/dm-dev
COPY . .

# Setup dm environment for ruby 2.6
RUN source /home/daryn.warriner/.rvm/scripts/rvm && rvm install 2.6 && gem update --system 3.2.3 && gem install bundler -v 2.4.22
# RUN BUNDLE_GEMFILE=Gemfile.2.6.6 bundle install

# Setup dm environment for ruby 2.7
RUN rvm install 2.7.8
# RUN rvm use 2.7.8 && BUNDLE_GEMFILE=Gemfile.2.7.8 bundle install

# Setup dm environment for ruby 3.2
RUN rvm install 3.2.2
# RUN rvm use 3.2.2 && BUNDLE_GEMFILE=Gemfile.3.2.2 bundle install

# Setup the thor tasks
#RUN thor install dm-dev/tasks.rb

CMD ["bash", "-l", "-c", "while [ true ]; do sleep 300; done"]
