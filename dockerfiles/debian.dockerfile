FROM debian:latest

RUN apt update
RUN apt install -y \
    build-essential iproute ruby-dev screen procps


COPY Gemfile /evesync/Gemfile

WORKDIR /evesync

# Installing other stuff
RUN gem install rake bundler
RUN bundle install --without development


# Adding all other files
COPY . /evesync
COPY ./config/example.conf /etc/evesync.conf

RUN rake
RUN rake install

EXPOSE "55432"

ENTRYPOINT ["screen", "bash"]
