FROM ruby:2.7.8-slim-bullseye
MAINTAINER Firespring "info.dev@firespring.com"
ARG USERNAME
ARG DM_DEV_INCLUDE

WORKDIR /usr/src

ARG TARGETARCH=amd64

RUN apt-get update \
    && DEPLIBS='zip unzip build-essential curl default-libmysqlclient-dev vim gpg gawk autoconf automake bison libgdbm-dev libncurses5-dev libsqlite3-dev libtool pkg-config sqlite3 libreadline-dev libssl-dev iputils-ping libxml2-dev jq git' \
    && apt-get install -y $DEPLIBS && mkdir -p /tmp/awscli/ && cd /tmp/awscli/ \
    && if [ -z "${TARGETARCH##*arm*}" ] ; then \
         curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
       else \
         curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip";  \
       fi \
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin \
    && rm -rf /tmp/awscli/ \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# install latest awscli and clean up
RUN apt-get update \
    && apt-get install -y python3-pip \
    && pip3 install --upgrade --no-cache-dir aws-encryption-sdk-cli==3.1.0 \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY --from=docker:dind /usr/local/bin /usr/local/bin

SHELL ["/bin/bash", "-l", "-c"]
RUN groupadd rvm
RUN useradd --create-home --shell /bin/bash --no-log-init -G rvm "${USERNAME}"

USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN git config --global --add safe.directory "/home/${USERNAME}/datamapper/dm-dev" \
    && for i in ${DM_DEV_INCLUDE}; do git config --global --add safe.directory "/home/${USERNAME}/datamapper/${i}"; done

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
    && \curl -sSL https://get.rvm.io | bash -s stable

## copy in the dm-dev repo
WORKDIR /home/${USERNAME}/datamapper/dm-dev
COPY . .

# Setup dm environment for ruby 2.6
# RUN source /home/${USERNAME}/.rvm/scripts/rvm && rvm install 2.6 && gem update --system 3.2.3 && gem install bundler -v 2.4.22
RUN rvm install 2.6 && gem update --system 3.2.3 && gem install bundler -v 2.4.22
RUN BUNDLE_GEMFILE=Gemfile.2.6.6 bundle install

# Setup dm environment for ruby 2.7
RUN rvm install 2.7.8
RUN rvm use 2.7.8 && BUNDLE_GEMFILE=Gemfile.2.7.8 bundle install

# Setup dm environment for ruby 3.2
RUN rvm install 3.2.2
RUN rvm use 3.2.2 && BUNDLE_GEMFILE=Gemfile.3.2.2 bundle install

WORKDIR /home/${USERNAME}/datamapper

CMD ["bash", "-l", "-c", "while [ true ]; do sleep 300; done"]
