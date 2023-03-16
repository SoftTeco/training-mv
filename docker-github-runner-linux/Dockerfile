# base image
FROM ubuntu:18.04 as build

#input GitHub runner version argument
ARG RUNNER_VERSION
ARG TERRAFORM_VERSION
ENV DEBIAN_FRONTEND=noninteractive

LABEL BaseImage="ubuntu:18.04"
LABEL RunnerVersion=${RUNNER_VERSION}
LABEL TerraformVersion=${TERRAFORM_VERSION}
LABEL test="test"

# update the base packages + add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker && apt-get install sudo

RUN sudo sed -i -e 's/mesg n .*true/tty -s \&\& mesg n/g' /root/.profile

# install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)
RUN apt-get install -y --no-install-recommends \
    curl \
    nodejs \
    wget \
    unzip \ 
    vim \
    git \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    golang-go 

RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz 

ADD terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

#install minikube
RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/local/bin/minikube 

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# add over the start.sh script
ADD scripts/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker
 
#RUN sudo dockerd
ADD ./.terraformrc /home/docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]

FROM alpine:20230208

COPY --from=build /home/docker/actions-runner/ /home/docker/actions-runner/
COPY --from=build /home/docker/actions-runner/bin.2.302.1 /home/docker/actions-runner/bin.2.302.1
RUN ls -la /home/docker/actions-runner
COPY --from=build /root/.profile /root/
COPY --from=build start.sh /home/docker/
COPY --from=build /home/docker/.terraformrc /home/docker/
COPY --from=build /usr/local/bin/terraform /home/docker/

RUN addgroup -S dockergr && adduser -S docker -G dockergr && chown -R docker ~docker && /home/docker/actions-runner/bin.2.302.1/installdependencies.sh
USER docker

ENTRYPOINT ["./start.sh"]

