# base image
FROM ubuntu:18.04

#input GitHub runner version argument
ARG RUNNER_VERSION
ARG TERRAFORM_VERSION
ENV DEBIAN_FRONTEND=noninteractive

LABEL BaseImage="ubuntu:18.04"
LABEL RunnerVersion=${RUNNER_VERSION}
LABEL TerraformVersion=${TERRAFORM_VERSION}
LABEL test="test"
LABEL new="test2"

# update the base packages + add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker && apt-get install sudo
#RUN sudo sed -i 's/mesg n || true/tty -s \&\& mesg n/' /root/.profile
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
    #sudo
    #numactl

#RUN export GOROOT=$(go1.18 env GOROOT) \
#RUN go install golang.org/dl/go1.20@latest && go1.20 download \
    #&& export GOROOT=$(go env GOROOT) \
    #&& export PATH=${GOROOT}/bin;${PATH} 
# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz 

# install terraform
#RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg \
#    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list \
#    && sudo apt update && sudo apt install terraform
ADD terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
#RUN wget https://go.dev/dl/go1.20.2.linux-amd64.tar.gz
#ADD go1.20.2.linux-amd64.tar.gz go1.20.2.linux-amd64.tar.gz
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

#install minikube
#RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/local/bin/minikube 

#install kubectl
#RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#RUN mkdir -p ~/.local/bin/kubectl
#RUN mv ./kubectl ~/.local/bin/kubectl
#COPY .kube /root/.kube
#COPY .minikube /root/.minikube
#RUN chmod +r ~/.kube/config
#RUN chmod +x ~/.local/bin/kubectl/ -R
#WORKDIR /root/.local/bin/kubectl/

#COPY .terraformrc ~/.terraformrc
#RUN mv .terraformrc ~/
# install providers    
#RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.2.linux-amd64.tar.gz && export PATH=$PATH:/usr/local/go/bin && . $HOME/.profile
#RUN cat $HOME/.profile
#RUN mkdir .terraform && cd .terraform && mkdir providers && cd providers && mkdir registry.terraform.io && cd registry.terraform.io && mkdir kreuzwerker \
    #&& cd kreuzwerker && mkdir docker && cd docker
    #&& git clone https://github.com/kreuzwerker/terraform-provider-docker.git && cd terraform-provider-docker \
    #&& make -f GNUmakefile \
    #&& make golangci-lint \
    #&& make build \
    #&& go build \
    #&& mv terraform-provider-docker ../ && cd ../../../ && rm -r terraform-provider-docker/
#COPY tf-docker.gz ./tf-docker.gz
#RUN gunzip tf-docker.gz && tar -xvf tf-docker && cd ../../../
#RUN cd .terraform/providers/registry.terraform.io/ && mkdir hashicorp \
    #&& cd hashicorp && mkdir kubernetes && cd kubernetes && git clone https://github.com/hashicorp/terraform-provider-kubernetes.git && cd terraform-provider-kubernetes
    #&& make build \
    #&& go build \
    #&& mv terraform-provider-kubernetes ../ && rm -r terraform-provider-kubernetes/
#COPY tf-kubernetes.gz ./tf-kubernetes.gz
#RUN gunzip tf-kubernetes.gz && tar -xvf tf-kubernetes
# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# add over the start.sh script
ADD scripts/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker
 
#
#RUN sudo dockerd
ADD ./.terraformrc /home/docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]