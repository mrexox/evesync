FROM centos:7.4.1708

# Installing dependencies first
RUN yum install -y ruby ruby-devel rubygem-bundler \
    make gcc gcc-c++ tmux iproute rpm-build epel-release git

RUN gem install rake

RUN printf "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri" > /root/.gemrc

WORKDIR /evesync

EXPOSE "55432"

COPY Gemfile ./Gemfile

RUN bundle install --without development

# Adding all other files
COPY . /evesync
RUN yum-builddep -y evesync.spec
