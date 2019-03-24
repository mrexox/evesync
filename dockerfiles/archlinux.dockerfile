FROM archlinux/base

RUN pacman -Sy --noconfirm \
    grep iproute2 ruby ruby-bundler \
    ruby-rake make gcc awk diffutils tmux




COPY Gemfile /sysmoon/Gemfile

WORKDIR /sysmoon

# Installing other stuff
RUN bundle install

# Adding all other files
COPY . /sysmoon
COPY ./config/example.conf /etc/sysmoon.conf

RUN rake
RUN rake install

EXPOSE "55432"

ENTRYPOINT ["/bin/tmux"]
