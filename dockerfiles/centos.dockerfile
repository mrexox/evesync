FROM centos:7.4.1708

# Installing dependencies first
RUN yum install -y ruby ruby-devel rubygem-bundler \
    make gcc g++ tmux iproute

RUN gem install rake

RUN printf "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri" > /root/.gemrc

WORKDIR /evesync

EXPOSE "55432"

ENTRYPOINT ["/bin/tmux"]

COPY Gemfile ./Gemfile

RUN bundle install --without development

# Adding all other files
COPY . /evesync
COPY ./config/example.conf /etc/evesync.conf

RUN rake
RUN rake install
