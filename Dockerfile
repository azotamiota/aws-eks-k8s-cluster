FROM ubuntu:latest

# Use an alternative mirror
RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install -y git

## Installing TFEnv
RUN git clone https://github.com/kamatama41/tfenv.git /usr/share/.tfenv && \
    ln -s /usr/share/.tfenv/bin/* /usr/local/bin/

RUN tfenv install latest && \
    tfenv install 0.12.21 && \
    tfenv use 0.12.21

WORKDIR /workspace

CMD ["bash"]