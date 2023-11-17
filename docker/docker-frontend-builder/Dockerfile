# Start from Ubuntu 20.04
FROM ubuntu:20.04

# Update package lists and install dependencies
RUN apt-get update && \
    apt-get install -y curl

# Install nvm (Node Version Manager)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Set up nvm environment variables
ENV NVM_DIR /root/.nvm
ENV SH_VERSION v18.0.0

SHELL ["/bin/bash", "-c"] 

# Install the latest version of Node.js using nvm
RUN source $NVM_DIR/nvm.sh && \ 
    nvm install $SH_VERSION && \
    nvm alias default $SH_VERSION && \
    nvm use default && \
    npm install -g yarn

# Set the working directory
WORKDIR /app

# Set the default command to start the shell
CMD ["/bin/bash"]
