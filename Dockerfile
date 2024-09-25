FROM  ubuntu:20.04
LABEL maintainer="icaro_martins98@hotmail.com"

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk-linux \
	ANDROID_SDK_ROOT=/opt/android-sdk-linux \
    NODE_VERSION=14.17.0 \
    IONIC_VERSION=4 \
    CORDOVA_VERSION=10.0.0 \
    GRADLE_VERSION=5.5.1

# Install basics
RUN apt-get update &&  \
    apt-get install -y git wget curl unzip ruby ruby-dev gcc make
	
# Install node
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs

RUN npm install -g cordova@"$CORDOVA_VERSION" && \
    npm install -g ionic@"$IONIC_VERSION"
	
RUN npm install -g sass \ 
    && npm rebuild node-sass

#ANDROID
#JAVA

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

#ANDROID STUFF
RUN echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y expect ant wget zipalign libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses6 lib32z1 qemu-kvm kmod && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android SDK
RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip -O android-commandline-tools.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip -q android-commandline-tools.zip -d /tmp/ \
    && mv /tmp/cmdline-tools/ ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm android-commandline-tools.zip && ls -la ${ANDROID_SDK_ROOT}/cmdline-tools/latest/

WORKDIR /opt/gradle
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
   && unzip gradle-${GRADLE_VERSION}-bin.zip -d /opt/gradle \
   && rm gradle-${GRADLE_VERSION}-bin.zip
   
ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV PATH=$PATH:$GRADLE_HOME/bin
RUN gradle --version

# Setup environment
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:/opt/gradle/gradle-"$GRADLE_VERSION"/bin

# Install sdk elements
#COPY tools /opt/tools

RUN yes | sdkmanager --licenses

RUN yes | sdkmanager --update --channel=3
# Please keep all sections in descending order!

RUN yes | sdkmanager  \
    "platforms;android-29" \
    "platforms;android-28" \
    "platforms;android-27" \
    "build-tools;29.0.3" \
    "build-tools;28.0.3" \
    "build-tools;27.0.3" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "add-ons;addon-google_apis-google-23" \
    "add-ons;addon-google_apis-google-22" \
    "add-ons;addon-google_apis-google-21"

WORKDIR /myApp
EXPOSE 8100 
