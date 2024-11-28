FROM ubuntu:24.10

ENV PATH="~/.local/bin:$PATH"
ENV TMUX_CONF="/usr/src/app/.tmux.conf"
ARG FFMPEG_ZIP_PATH=/usr/local/bin/ffmpeg-6.1-linux-64.zip
ARG FFMPEG_BIN_URL=https://github.com/ffbinaries/ffbinaries-prebuilt/releases/download/v6.1/ffmpeg-6.1-linux-64.zip

RUN apt-get update && apt-get install -y \
    curl git gnupg unzip build-essential tmux psmisc \
    libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev libbz2-dev libffi-dev liblzma-dev

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1

RUN echo '. ~/.asdf/asdf.sh && tmux() { if [ -n "$TMUX_CONF" ]; then command tmux -f "$TMUX_CONF" "$@"; else command tmux "$@"; fi; }' >> ~/.bashrc

COPY .tool-versions /root/

RUN bash -c 'source ~/.asdf/asdf.sh && \
    cat /root/.tool-versions | awk "{print \$1}" | xargs -I {} asdf plugin add {} && \
    asdf install'
RUN bash -c 'sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin'
RUN curl -L -o ${FFMPEG_ZIP_PATH} ${FFMPEG_BIN_URL} && \
	unzip -d /usr/local/bin/ ${FFMPEG_ZIP_PATH} && \
	rm -rf ${FFMPEG_ZIP_PATH}

RUN bash -c "source ~/.bashrc" && \
	git config --global --add safe.directory /usr/src/app

WORKDIR /usr/src/app

COPY . . 

RUN /root/.asdf/shims/go mod download

CMD ["tail", "-f", "/dev/null"]
