FROM ubuntu:16.04
MAINTAINER Cristian Balas
# Thanks to Niklas Merz
# Adapted from https://github.com/NiklasMerz/ionic-build-android-ci-docker

# Install apt packages
RUN apt-get update \
    && apt-get install -y \
        nodejs \
        git \
        lib32stdc++6 \
        lib32z1 \
        s3cmd \
        build-essential \
        curl \
        wget \
        unzip \
        openjdk-8-jdk-headless \
        sendemail \
        libio-socket-ssl-perl \
        libnet-ssleay-perl \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Download and untar Android SDK tools
RUN mkdir -p /usr/local/android-sdk-linux
RUN wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip -O tools.zip
RUN unzip tools.zip -d /usr/local/android-sdk-linux
RUN rm tools.zip

# Set environment variable
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$PATH

RUN mkdir $ANDROID_HOME/licenses
RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license
RUN echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license
RUN echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license

# Update and install using sdkmanager
RUN $ANDROID_HOME/tools/bin/sdkmanager "tools" "platform-tools"
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;27.0.1" "build-tools;26.0.2" "build-tools;25.0.3"
RUN $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-27" "platforms;android-26" "platforms;android-25" "platforms;android-24" "platforms;android-23"
RUN $ANDROID_HOME/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository"
RUN $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"


RUN wget https://services.gradle.org/distributions/gradle-4.1-bin.zip && mkdir /opt/gradle && unzip -d /opt/gradle gradle-4.1-bin.zip && rm -f gradle-4.1-bin.zip
ENV PATH $PATH:/opt/gradle/gradle-4.1/bin


# Install npm packages
RUN npm i -g \
        ionic@3.19.1 \
        cordova@8.0.0 \
        gulp \
        grunt \
        phonegap

# Build empty app so that gradle does the requirement downloads. Do the latest android ver and 6.4
RUN cd /opt \
    && ionic start testApp blank --cordova --no-git --no-link \
    && cd testApp \
    && ionic cordova build android \
    && ionic cordova platform remove android \
    && ionic cordova platform add android@6.4.0 \
    && ionic cordova build android \
    && cd /opt \
    && rm -rf testApp

WORKDIR /app
