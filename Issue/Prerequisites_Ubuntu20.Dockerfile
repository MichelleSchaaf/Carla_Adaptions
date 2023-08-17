FROM ubuntu:20.04

USER root

ARG EPIC_USER=user
ARG EPIC_PASS=pass
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update ; \
    apt-get install -y wget software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add - && \
    apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-8 main" && \
    apt-get update ; \
    apt-get install -y build-essential \
      clang-10  \
      lld-10  \
      g++-7  \
      cmake  \
      ninja-build  \
      libvulkan1  \
      python \
      python3  \
      python3-dev  \
      python3-pip  \
      libpng-dev  \
      libtiff5-dev  \
      libjpeg-dev  \
      tzdata  \
      sed  \
      curl  \
      unzip  \
      autoconf  \
      libtool  \
      rsync  \
      libxml2-dev  \
      git

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

RUN pip3 install --upgrade pip && \
    pip3 install -Iv setuptools==47.3.1 && \
    pip3 install distro && \
    pip3 install wheel auditwheel

RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-10/bin/clang++ 180
RUN update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-10/bin/clang 180

RUN useradd -m carla
COPY --chown=carla:carla . /home/carla
USER carla
WORKDIR /home/carla
ENV UE4_ROOT /home/carla/UE4.26

RUN git clone --depth 1 -b carla "https://${EPIC_USER}:${EPIC_PASS}@github.com/CarlaUnreal/UnrealEngine.git" ${UE4_ROOT}

RUN cd $UE4_ROOT && \
  ./Setup.sh
RUN cd $UE4_ROOT && \
    ./GenerateProjectFiles.sh
RUN cd $UE4_ROOT && \
    make

WORKDIR /home/carla/