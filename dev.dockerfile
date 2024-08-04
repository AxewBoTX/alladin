FROM docker.io/golang:1.22.4

WORKDIR /usr/src/app

ENV PATH="/usr/local/bin:${PATH}"

ARG FFMPEG_ZIP_PATH=/usr/local/bin/ffmpeg-6.1-linux-64.zip
ARG FFMPEG_BIN_URL=https://github.com/ffbinaries/ffbinaries-prebuilt/releases/download/v6.1/ffmpeg-6.1-linux-64.zip

COPY . .

RUN apt-get update && \
	apt-get install -y curl tmux psmisc unzip

RUN curl -L -o ${FFMPEG_ZIP_PATH} ${FFMPEG_BIN_URL} && \
	unzip -d /usr/local/bin/ ${FFMPEG_ZIP_PATH} && \
	rm -rf ${FFMPEG_ZIP_PATH}

RUN bash -c "source ~/.bashrc" && \
	git config --global --add safe.directory /usr/src/app

RUN go mod download && \
 	go install github.com/go-task/task/v3/cmd/task@latest

CMD ["tail", "-f", "/dev/null"]
