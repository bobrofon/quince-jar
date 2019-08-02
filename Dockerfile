FROM ubuntu:bionic AS base
RUN \
	apt-get update && \
	apt-get install --no-install-recommends -y openjdk-8-jdk ninja-build && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ENV \
	JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
	PATH=$PATH:/opt/cmake/cmake-3.15.1-Linux-x86_64/bin

FROM base AS builder
ARG QT_MAJOR_VERSION=5
ARG QT_MINOR_VERSION=13
ARG QT_PATCH_VERSION=0
ARG QT_SHORT_VERSION=$QT_MAJOR_VERSION.$QT_MINOR_VERSION
ARG QT_LONG_VERSION=$QT_SHORT_VERSION.$QT_PATCH_VERSION
ENV QT_INSTALLER=qt-opensource-linux-x64-$QT_LONG_VERSION.run
ARG QT_INSTALLER_URL=https://download.qt.io/archive/qt/$QT_SHORT_VERSION/$QT_LONG_VERSION/$QT_INSTALLER
ENV QT_EXTRACTOR=extract-qt-installer
ARG QT_EXTRACTOR_URL=https://raw.githubusercontent.com/benlau/qtci/master/bin/$QT_EXTRACTOR
ADD $QT_INSTALLER_URL ./
ADD $QT_EXTRACTOR_URL ./
RUN chmod +x $QT_INSTALLER $QT_EXTRACTOR

RUN apt-get update
RUN apt-get install --no-install-recommends -y libdbus-1-3 libfreetype6 libfontconfig1 libx11-6 libx11-xcb1

ARG QT_VERSION_CODE=${QT_MAJOR_VERSION}${QT_MINOR_VERSION}${QT_PATCH_VERSION}
ARG QT_ANDROID_PACKAGE=qt.qt$QT_MAJOR_VERSION.$QT_VERSION_CODE.android
ENV QT_CI_PACKAGES=${QT_ANDROID_PACKAGE}_x86,${QT_ANDROID_PACKAGE}_x86_64,${QT_ANDROID_PACKAGE}_arm64_v8a,${QT_ANDROID_PACKAGE}_armv7
RUN ./$QT_EXTRACTOR $QT_INSTALLER /opt/qt

ARG ANDROID_SDK_VERSION=4333796
ENV ANDROID_SDK=sdk-tools-linux-${ANDROID_SDK_VERSION}.zip
ARG ANDROID_SDK_URL=https://dl.google.com/android/repository/$ANDROID_SDK
ADD $ANDROID_SDK_URL ./
RUN apt-get install --no-install-recommends -y unzip
RUN mkdir -p /opt/android
RUN unzip -d /opt/android $ANDROID_SDK
RUN yes | /opt/android/tools/bin/sdkmanager --install 'build-tools;29.0.1' 'ndk;20.0.5594570' 'platforms;android-29'

ARG CMAKE_VERSION=3.15.1
ENV CMAKE=cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz
ARG CMAKE_URL=https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/$CMAKE
RUN mkdir -p /opt/cmake
ADD $CMAKE_URL ./
RUN tar -xzf $CMAKE -C /opt/cmake

FROM base AS jar

COPY --from=builder /opt /opt

WORKDIR /src
