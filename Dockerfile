FROM ubuntu:18.04

# 使っていない値を指定する
ENV DISPLAY=:1

# ミラーの変更
RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@' /etc/apt/sources.list

# 諸々インストール
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt update \
    && apt install -y x11-xserver-utils \
                   xinit \
                   tzdata \
                   language-pack-ja-base \
                   language-pack-ja \
                   sudo \
                   jwm \
                   lxterminal \
                   alsa-utils \
                   pulseaudio \
                   pulseaudio-utils \
                   fonts-ipafont-gothic \
                   dbus-x11 \
                   fcitx-mozc \
                   fcitx-imlist \
                   vim-gtk3 \
                   curl \
                   feh \
                   vlc \
                   mupdf \
                   ranger \
                   w3m-img \
                   ffmpegthumbnailer
# 音
ENV PULSE_SERVER=unix:/tmp/pulse/native \
    PULSE_COOKIE=/tmp/pulse/cookie

# 日本語
RUN locale-gen ja_JP.UTF-8
ENV LANG=ja_JP.UTF-8

# タイムゾーン
ENV TZ=Asia/Tokyo

# 日本語入力
ENV GTK_IM_MODULE=fcitx \
    QT_IM_MODULE=fcitx \
    XMODIFIERS=@im=fcitx \
    DefalutIMModule=fcitx

# docker内で使うユーザを作成する。
# ホストと同じUIDにする。ホストのpulseaudioのcookieを触るときに、permision deniedにならない。
ARG DOCKER_UID=1000
ARG DOCKER_USER=docker
ARG DOCKER_PASSWORD=docker
RUN useradd -m --uid ${DOCKER_UID} --groups sudo --shell /bin/bash ${DOCKER_USER} && echo ${DOCKER_USER}:${DOCKER_PASSWORD} | chpasswd

WORKDIR /home/${DOCKER_USER}

# google-chrome
RUN curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
      && apt install -y ./google-chrome-stable_current_amd64.deb \
      && rm google-chrome-stable_current_amd64.deb

# ターミナル、bash、ウィンドウマネージャの設定
COPY ./lxterminal.conf  ./.config/lxterminal/lxterminal.conf
COPY ./bashrc  ./.bashrc
COPY ./jwmrc  ./.jwmrc

# cuiファイルマネージャの設定
RUN ranger -r ./.config/ranger --copy-config=all
RUN sed -i 's/\(set preview_images \)false/\1true/' ./.config/ranger/rc.conf
RUN sed -i 's/###video/video/;s/.*\(ffmpegthumbnailer.*\)/\1/' ./.config/ranger/scope.sh

RUN mkdir -p ./.local/share/fonts && \
    curl -L https://github.com/tonsky/FiraCode/raw/master/distr/ttf/{FiraCode-Regular.ttf} -o ./.local/share/fonts/#1 && \
    chown -R ${DOCKER_USER} ./.local && \
    fc-cache

# 使用するかもしれないディレクトリの生成
RUN mkdir mnt Downloads

# 所有者をrootから変更する
RUN chown -R ${DOCKER_USER} ./

USER ${DOCKER_USER}

CMD jwm
