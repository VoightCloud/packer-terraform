FROM alpine:3.15.0

LABEL maintainer="jeff@voight.org"
ENV GOPATH="/root/.go"

RUN echo "===> Installing sudo to emulate normal OS behavior..."  && \
    apk --update add sudo                                         && \
    apkArch="$(apk --print-arch)"                                 && \
    case "$apkArch" in \
        aarch64) export ARCH='arm64' ;; \
        x86_64) export ARCH='amd64' ;; \
    esac                                                          && \
    echo "===> Adding openssl, go, and xorriso runtime..."        && \
    apk --update add openssl xorriso go git ca-certificates       && \
    \
    echo "===> Installing Hashicorp Packer" && \
    wget "https://releases.hashicorp.com/packer/1.7.8/packer_1.7.8_linux_${ARCH}.zip" && \
    unzip "packer_1.7.8_linux_${ARCH}.zip" -d /usr/local/bin      && \
    mkdir -p /root/.packer.d/plugins                              && \
    rm -f "packer_1.7.8_linux_${ARCH}.zip"                        && \
    \
    echo "===> Installing Hashicorp Terraform"                    && \
    wget "https://releases.hashicorp.com/terraform/1.1.2/terraform_1.1.2_linux_${ARCH}.zip" && \
    unzip "terraform_1.1.2_linux_${ARCH}.zip" -d /usr/local/bin   && \
    rm -f "terraform_1.1.2_linux_${ARCH}.zip"                     && \
    \
    echo "===> Build packer-plugin-proxmox"                       && \
    git clone https://github.com/VoightCloud/packer-plugin-proxmox.git && \
    cd packer-plugin-proxmox                                      && \
    go build                                                      && \
    cp packer-plugin-proxmox /root/.packer.d/plugins              && \
    cd ..                                                         && \
    rm -rf packer-plugin-proxmox

ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /root

# default command: display packer version
CMD [ "packer", "--version" ]
