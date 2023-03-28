FROM catthehacker/ubuntu:act-22.04

#ARG RUNNER_VERSION
ARG TERRAFORM_VERSION
ENV DEBIAN_FRONTEND=noninteractive

RUN sudo apt-get update && sudo apt-get install python3-pip -y && sudo pip3 install python-dateutil && sudo pip3 install requests && \
    sudo sed -i -e 's/mesg n .*true/tty -s \&\& mesg n/g' /root/.profile

# cd into the user directory, download and unzip the github actions runner
#RUN cd /home/docker_user && mkdir actions-runner && cd actions-runner \
    #&& curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    #&& tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz 

ADD terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

#install minikube
RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/local/bin/minikube 


#install helm
#RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null && \
    #sudo apt-get install apt-transport-https --yes && \
    #echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    #sudo apt-get update && \
    #sudo apt-get install helm

#RUN chown -R docker_user ~docker_user && /home/docker_user/actions-runner/bin/installdependencies.sh

# add over the start.sh script
#ADD scripts/start.sh start.sh

# make the script executable
#RUN chmod +x start.sh

# set the user to "docker" so all subsequent commands are run as the docker user
#USER docker
 
#RUN sudo dockerd
ADD ./.terraformrc /root/
ADD ./ca.crt /root/.minikube/
#ADD ./client.crt /root/.kube/
#ADD ./client.key /root/.kube/
ADD ./config /root/
ADD ./.minikube/ /root/.minikube/

RUN mkdir /compose_data

ADD ./wordpress-dev-data /compose_data
ADD ./wordpress-prod-data /compose_data
ADD ./mysql-dev-data /compose_data
ADD ./mysql-prod-data /compose_data
ADD ./config.json /root/.docker/config.json

#RUN minikube start -p minikube-2
# set the entrypoint to the start.sh script
#ENTRYPOINT ["./start.sh"]

