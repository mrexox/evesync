FROM centos:7.4.1708

# Installing dependencies first
RUN yum install -y ruby ruby-devel rubygem-bundler \
    make gcc g++ tmux iproute

COPY Gemfile /sysmoon/Gemfile

WORKDIR /sysmoon

# Installing other stuff
RUN bundle

# Adding all other files
COPY . /sysmoon
COPY ./sysmoon.conf /etc/sysmoon.conf

RUN rake

EXPOSE "55432"

ENTRYPOINT ["/bin/tmux"]
