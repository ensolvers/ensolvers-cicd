FROM ubuntu:22.04
ARG timezone
ENV TZ=${timezone}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update
RUN apt install -y openjdk-21-jdk awscli mysql-client wget

RUN apt-get update && apt-get install -y gnupg2

# Set default value for the CHROME_VERSION_URL
ARG CHROME_VERSION_URL="https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE"

# Install the latest version of Google Chrome
RUN apt-get update && apt-get install -y wget
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get install -y google-chrome-stable

RUN apt-get update && apt-get install -y unzip

# Install the latest version of Chrome Driver
RUN CHROME_VERSION=$(wget -qO- ${CHROME_VERSION_URL}) \
    && wget -q -O /tmp/chromedriver-linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${CHROME_VERSION}/linux64/chromedriver-linux64.zip
RUN unzip /tmp/chromedriver-linux64.zip -d /usr/local/bin/

# Install the latest version of Chromium Browser
RUN apt-get update && apt-get install -y chromium-browser

# Set the path to Chrome Driver in your code
ENV PATH="/usr/local/bin:${PATH}"

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN apt-get install dos2unix

RUN dos2unix /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
RUN wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-agent.jar -O /newrelic.jar

CMD ["/docker-entrypoint.sh"]