FROM ubuntu:18.04

COPY common.sh /
RUN bash /common.sh

COPY cmake.sh /
RUN bash /cmake.sh

COPY xargo.sh /
RUN bash /xargo.sh

RUN git clone --depth 1 https://github.com/raspberrypi/tools.git /pi-tools && \
    mv $(readlink -f /pi-tools/arm-bcm2708/arm-linux-gnueabihf) /usr/arm-linux-gnueabihf && \
    rm -r /pi-tools

ENV PATH /usr/arm-linux-gnueabihf/bin:$PATH

COPY qemu.sh /
RUN /qemu.sh arm

ENV firmware="1.20200601"

RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends wget \
    && wget -O - https://github.com/raspberrypi/firmware/archive/$firmware.tar.gz | tar -xzf - -C / --strip-components 2 firmware-$firmware/hardfp/opt/vc \
    && apt-get purge wget -y --auto-remove

RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends \
    file \
    rsync \
    openssh-client \
    libnss-wrapper && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
    QEMU_LD_PREFIX=/usr/arm-linux-gnueabihf/arm-linux-gnueabihf \
    LD_LIBRARY_PATH=/usr/arm-linux-gnueabihf/lib:/usr/arm-linux-gnueabihf/arm-linux-gnueabihf/sysroot/lib:/opt/vc/lib \
    RUST_TEST_THREADS=1
