# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# @trenpixster wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return
# ----------------------------------------------------------------------------

# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
#
# Usage Example : Run One-Off commands
# where <VERSION> is one of the baseimage-docker version numbers.
# See : https://github.com/phusion/baseimage-docker#oneshot for more examples.
#
#  docker run --rm -t -i phusion/baseimage:<VERSION> /sbin/my_init -- bash -l
#
# Thanks to @hqmq_ for the heads up
FROM phusion/baseimage:0.9.18
MAINTAINER Nizar Venturini @trenpixster

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT 2016-10-23

# Set correct environment variables.

# Setting ENV HOME does not seem to work currently. HOME is unset in Docker container.
# See bug : https://github.com/phusion/baseimage-docker/issues/119
#ENV HOME /root
# Workaround:
RUN echo /root > /etc/container_environment/HOME

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Baseimage-docker enables an SSH server by default, so that you can use SSH
# to administer your container. In case you do not want to enable SSH, here's
# how you can disable it. Uncomment the following:
#RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /tmp

# See : https://github.com/phusion/baseimage-docker/issues/58
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN echo "deb http://packages.erlang-solutions.com/ubuntu trusty contrib" >> /etc/apt/sources.list && \
    apt-key adv --fetch-keys http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && \
    apt-get -qq update && apt-get install -y \
    esl-erlang=1:18.2 \
    git \
    unzip \
    build-essential \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and Install Specific Version of Elixir
WORKDIR /elixir
RUN wget -q https://github.com/elixir-lang/elixir/releases/download/v1.3.4/Precompiled.zip && \
    unzip Precompiled.zip && \
    rm -f Precompiled.zip && \
    ln -s /elixir/bin/elixirc /usr/local/bin/elixirc && \
    ln -s /elixir/bin/elixir /usr/local/bin/elixir && \
    ln -s /elixir/bin/mix /usr/local/bin/mix && \
    ln -s /elixir/bin/iex /usr/local/bin/iex

# Install local Elixir hex and rebar
RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix local.rebar --force

RUN apt-get -y install build-essential


WORKDIR /

RUN mkdir /app

WORKDIR /app

COPY ./ ./


RUN rm -rf ./_build || true
RUN rm -rf ./deps || true
RUN mix do deps.get
RUN mix deps.compile
RUN mix test
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix release
EXPOSE 30050 30051 30052 31000 31001 31002 31003 31004 31005 31006 31007 31008 31009 31010 31011 31012 31013 31014 31015 31016 31017 31018 31019 31020 31021 31022 31023 31024 31025 31026 31027 31028 31029 31030 31031 31032 31033 31034 31035 31036 31037 31038 31039 31040 31041 31042 31043 31044 31045 31046 31047 31048 31049 31050 31051 31052 31053 31054 31055 31056 31057 31058 31059 31060 31061 31062 31063 31064 31065 31066 31067 31068 31069 31070 31071 31072 31073 31074 31075 31076 31077 31078 31079 31080 31081 31082 31083 31084 31085 31086 31087 31088 31089 31090 31091 31092 31093 31094 31095 31096 31097 31098 31099 31100
CMD /app/rel/zmq_broker/bin/zmq_broker foreground

