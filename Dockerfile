FROM erlang:21

ENV DEBIAN_FRONTEND noninteractive

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.7.4" \
	LANG=C.UTF-8

RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="c7c87983e03a1dcf20078141a22355e88dadb26b53d3f3f98b9a9268687f9e20" \
	&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/src/elixir \
	&& tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& make install clean

RUN apt-get update \
  && apt-get install -y zsh \
	&& apt-get install -y inotify-tools \
	&& apt-get install -y sudo \
	&& apt-get install -y nano

RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo bash - \
	&& apt-get install -y nodejs

RUN mix local.hex --force \
	&& mix archive.install hex phx_new 1.4.0 --force \
	&& mix local.rebar --force

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

RUN wget https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz -qO - | tar -zxC /usr/local/bin

CMD ["/bin/zsh"]