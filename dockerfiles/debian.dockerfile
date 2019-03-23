FROM debian:latest

RUN apt update
RUN apt install -y \
    build-essential iproute ruby-dev screen procps


COPY Gemfile /sysmoon/Gemfile

WORKDIR /sysmoon

# Installing other stuff
RUN gem install rake bundler
RUN bundle install


# Adding all other files
COPY . /sysmoon
COPY ./config/example.conf /etc/sysmoon.conf

RUN rake build
RUN rake install

EXPOSE "55432"

ENTRYPOINT ["screen"]
