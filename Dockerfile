FROM ubuntu:22.04

# 避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive

# 安装 Firefox 和中文支持
RUN apt-get update && \
    apt-get install -y \
        firefox \
        language-pack-zh-hans \
        fonts-noto-cjk \
        dbus-x11 \
        x11-utils \
        wget \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 设置中文环境
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 复制你的启动脚本（如果有）
COPY start-firefox.sh /start-firefox.sh
RUN chmod +x /start-firefox.sh

CMD ["/start-firefox.sh"]
