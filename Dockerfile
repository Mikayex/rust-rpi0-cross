FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    cmake \
    gcc \
    libc6-dev \
    make \
    pkg-config \
    git \
    automake \
    libtool \
    m4 \
    autoconf \
    make \
    file \
    binutils \
    rsync \
    openssh-client \
    libnss-wrapper \
    llvm-3.9-dev libclang-3.9-dev clang-3.9

COPY xargo.sh /
RUN bash /xargo.sh

RUN git clone --depth 1 https://github.com/raspberrypi/tools.git /pi-tools && \
    mv $(readlink -f /pi-tools/arm-bcm2708/arm-linux-gnueabihf) /usr/arm-linux-gnueabihf && \
    rm -r /pi-tools

ENV PATH /usr/arm-linux-gnueabihf/bin:$PATH

COPY openssl.sh qemu.sh /
RUN bash /openssl.sh linux-armv4 arm-linux-gnueabihf- && \
    bash /qemu.sh arm

ENV firmware="1.20190215"

RUN apt-get update \
  && apt-get install -y wget \
  && wget -O - https://github.com/raspberrypi/firmware/archive/$firmware.tar.gz | tar -xzf - -C / --strip-components 2 firmware-$firmware/hardfp/opt/vc \
  && apt-get purge wget -y --auto-remove \
  && rm -rf /var/lib/apt/lists/*

ENV NSS_WRAPPER_PASSWD=/tmp/passwd NSS_WRAPPER_GROUP=/tmp/group

RUN for path in "$NSS_WRAPPER_PASSWD" "$NSS_WRAPPER_GROUP"; do \
      touch $path && chmod 666 $path ; done

COPY nss-wrap.sh /nss-wrap.sh

RUN echo "StrictHostKeyChecking=no\nControlMaster auto\nControlPath ~/.ssh/control:%h:%p:%r\nControlPersist 600" >> /etc/ssh/ssh_config
COPY upload_emulate_execute.sh /

ENV HOME=/tmp CARGO_TARGET_ARM_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc \
    CARGO_TARGET_ARM_UNKNOWN_LINUX_GNUEABIHF_RUNNER=/upload_emulate_execute.sh \
    CC_arm_unknown_linux_gnueabihf=arm-linux-gnueabihf-gcc \
    CXX_arm_unknown_linux_gnueabihf=arm-linux-gnueabihf-g++ \
    OPENSSL_DIR=/openssl \
    OPENSSL_INCLUDE_DIR=/openssl/include \
    OPENSSL_LIB_DIR=/openssl/lib \
    QEMU_LD_PREFIX=/usr/arm-linux-gnueabihf/arm-linux-gnueabihf \
    LD_LIBRARY_PATH=/usr/arm-linux-gnueabihf/lib:/usr/arm-linux-gnueabihf/arm-linux-gnueabihf/sysroot/lib:/opt/vc/lib \
    RUST_TEST_THREADS=1
