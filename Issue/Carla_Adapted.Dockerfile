FROM carla-prerequisites:latest
#FROM carla-prerequisites_ubuntu20:latest

ARG GIT_BRANCH

RUN export UE4_ROOT=~/UE4.26

WORKDIR /home/carla

RUN cd /home/carla/
RUN git clone https://github.com/MichelleSchaaf/Carla_Adaptions.git

RUN cd /home/carla/ && \
  if [ -z ${GIT_BRANCH+x} ]; then git clone --depth 1 https://github.com/carla-simulator/carla.git; \
  else git clone --depth 1 --branch $GIT_BRANCH https://github.com/carla-simulator/carla.git; fi

RUN cd /home/carla/carla && \
    ./Update.sh && \
    make PythonAPI

RUN rsync -av /home/carla/Carla_Adaptions/PythonAPI /home/carla/carla/
RUN rsync -av /home/carla/Carla_Adaptions/LibCarla /home/carla/carla/
RUN rsync -av /home/carla/Carla_Adaptions/Unreal /home/carla/carla/

RUN cd /home/carla/carla && \
    make PythonAPI
RUN cd /home/carla/carla && \
    make build.utils
RUN cd /home/carla/carla && \
    make package