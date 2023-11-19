# Start from Ubuntu 20.04
FROM ubuntu:20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install dependencies
RUN apt-get update && \
    apt-get install -y curl python3 python3-pip gettext jq git

# Install NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

ENV NVM_DIR /root/.nvm

SHELL ["/bin/bash", "-c"] 

# Install the latest version of Node.js using nvm
RUN source $NVM_DIR/nvm.sh && \ 
    nvm install 18 && \
    nvm use default && \
    npm install -g yarn

# Install AWS CLI
RUN pip3 install awscli

# Set the working directory
WORKDIR /app

# Set the default command to start the shell
CMD ["/bin/bash"]
