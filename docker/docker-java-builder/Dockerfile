FROM ubuntu:18.04

ARG JAVA_FLAVOR

RUN apt-get update
RUN apt-get install -y python3 python3-distutils python3-pip jq curl gettext-base

# install java
RUN curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | \
    JABBA_COMMAND="install ${JAVA_FLAVOR} -o /jdk" bash
ENV JAVA_HOME "/jdk"
ENV PATH "$JAVA_HOME/bin:$PATH"

RUN curl https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz > /tmp/maven.tar.gz
RUN tar -xvzf /tmp/maven.tar.gz -C "/"

ENV MAVEN_HOME "/apache-maven-3.6.3"
ENV MAVEN_CONFIG "/root/.m2"
ENV PATH "/apache-maven-3.6.3/bin:$PATH"

# setup for AWS CLI
RUN pip3 install --upgrade awscli
ENV PATH "~/.local/bin:$PATH"

# setup for node
RUN curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
RUN chmod +x nodesource_setup.sh
RUN ./nodesource_setup.sh
RUN apt-get install -y nodejs

# setup for docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io
