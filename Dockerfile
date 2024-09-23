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
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash && \ 
    . ~/.nvm/nvm.sh &&  \
	nvm install 14 && \
	node -v && \
	npm -v

RUN . ~/.nvm/nvm.sh &&  \
    npm install -g cordova@"$CORDOVA_VERSION" && \
    npm install -g ionic@"$IONIC_VERSION" && \
    npm cache clear --force

RUN apt-get install -y --no-install-recommends autoconf automake bzip2 dpkg-dev file g++ gcc imagemagick libbz2-dev libc6-dev libcurl4-openssl-dev libdb-dev libevent-dev libffi-dev libgdbm-dev libglib2.0-dev libgmp-dev libjpeg-dev libkrb5-dev liblzma-dev libmagickcore-dev libmagickwand-dev libmaxminddb-dev libncurses5-dev libncursesw5-dev libpng-dev libpq-dev libreadline-dev libsqlite3-dev libssl-dev libtool libwebp-dev libxml2-dev libxslt-dev libyaml-dev make patch unzip xz-utils zlib1g-dev $( if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then echo 'default-libmysqlclient-dev'; else echo 'libmysqlclient-dev'; fi )

	
RUN . ~/.nvm/nvm.sh &&  \
    npm install -g sass;

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



# Install Gradle
WORKDIR /opt/gradle
RUN curl -L https://downloads.gradle-dn.com/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle-${GRADLE_VERSION}-bin.zip
RUN unzip gradle-${GRADLE_VERSION}-bin.zip
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

RUN yes | sdkmanager \
    "platforms;android-29" \
    "platforms;android-28" \
    "platforms;android-27" \
    "build-tools;29.0.3" \
    "build-tools;28.0.3" \
    "build-tools;27.0.3" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
    "add-ons;addon-google_apis-google-23" \
    "add-ons;addon-google_apis-google-22" \
    "add-ons;addon-google_apis-google-21"

# Test First Build so that it will be faster later
RUN cd /myApp && \
    ionic cordova build android --prod --no-interactive --release

WORKDIR /myApp
EXPOSE 8100 
