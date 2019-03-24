FROM centos:7.4.1708

# Installing dependencies first
RUN yum install -y ruby ruby-devel rubygem-bundler \
    make gcc g++ tmux iproute

COPY Gemfile /sysmoon/Gemfile

WORKDIR /sysmoon

# Installing other stuff
RUN gem install rake
RUN bundle install

# Adding all other files
COPY . /sysmoon
COPY ./config/example.conf /etc/sysmoon.conf

RUN rake
RUN rake install

EXPOSE "55432"

ENTRYPOINT ["/bin/tmux"]
