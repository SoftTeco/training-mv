FROM catthehacker/ubuntu:act-22.04

ARG RUNNER_VERSION
ARG TERRAFORM_VERSION
ENV DEBIAN_FRONTEND=noninteractive

RUN sudo apt-get update && sudo apt-get install python3-pip -y && sudo pip3 install python-dateutil && sudo pip3 install requests && \
    useradd -m docker_user && sudo sed -i -e 's/mesg n .*true/tty -s \&\& mesg n/g' /root/.profile

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker_user && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz 

ADD terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN chown -R docker ~docker && /home/docker_user/actions-runner/bin/installdependencies.sh

# add over the start.sh script
ADD scripts/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker_user
 
#
#RUN sudo dockerd
ADD ./.terraformrc /home/docker_user

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]