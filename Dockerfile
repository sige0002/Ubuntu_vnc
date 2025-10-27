FROM nvidia/cuda:12.6.0-cudnn-runtime-ubuntu22.04

# 非対話的インストールとタイムゾーン設定
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# 基本ツールとVNC環境
RUN apt-get update && apt-get install -y \
    python3 python3-pip git wget curl vim \
    xfce4 xfce4-goodies \
    x11vnc xvfb \
    novnc websockify \
    supervisor \
    tzdata \
    firefox \
    xclip xsel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PyTorch (CUDA 12.x対応ビルド) をインストール
RUN python3 -m pip install --upgrade pip \
 && python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# VNC設定
RUN mkdir -p /root/.vnc
RUN x11vnc -storepasswd 1234 /root/.vnc/passwd

# Supervisor設定
RUN echo '[program:xvfb]\ncommand=/usr/bin/Xvfb :0 -screen 0 1280x800x24 +extension GLX +render -noreset\nautorestart=true' > /etc/supervisor/conf.d/xvfb.conf \
 && echo '[program:x11vnc]\ncommand=/usr/bin/x11vnc -forever -usepw -create -rfbauth /root/.vnc/passwd -display :0\nautorestart=true' > /etc/supervisor/conf.d/x11vnc.conf \
 && echo '[program:novnc]\ncommand=/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 6080\nautorestart=true' > /etc/supervisor/conf.d/novnc.conf \
 && echo '[program:xfce4]\ncommand=env DISPLAY=:0 /usr/bin/startxfce4\nautorestart=true' > /etc/supervisor/conf.d/xfce4.conf

# 環境変数設定
ENV DISPLAY=:0

EXPOSE 6080

CMD ["/usr/bin/supervisord", "-n"]
