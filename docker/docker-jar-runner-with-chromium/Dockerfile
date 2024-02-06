FROM ubuntu:22.04
ARG timezone
ENV TZ=${timezone}
# Set the version of Chrome
ENV CHROME_VERSION 121.0.6167.85

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update
RUN apt install -y openjdk-17-jdk awscli mysql-client wget

# Install the latest version of Google Chrome
RUN apt-get update && apt-get install -y wget
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get install -y google-chrome-stable=${CHROME_VERSION}-1

# Install the latest version of Chrome Driver
RUN wget -q -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/${CHROME_VERSION}/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# Install the latest version of Chromium Browser
RUN apt-get update && apt-get install -y  chromium-browser=${CHROME_VERSION}-1

# Set the path to Chrome Driver in your code
ENV PATH="/usr/local/bin:${PATH}"

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/8.0.1/newrelic-agent-8.0.1.jar -O /newrelic.jar

CMD ["./docker-entrypoint.sh"]