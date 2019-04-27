FROM archlinux/base

RUN pacman -Sy --noconfirm \
    grep iproute2 ruby ruby-bundler \
    ruby-rake make gcc awk diffutils tmux




COPY Gemfile /evesync/Gemfile

WORKDIR /evesync

# Installing other stuff
RUN bundle install --without development

# Adding all other files
COPY . /evesync
COPY ./config/example.conf /etc/evesync.conf

RUN rake
RUN rake install

EXPOSE "55432"

ENTRYPOINT ["/bin/tmux"]
