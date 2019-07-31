FROM ubuntu:bionic

RUN \
	export TEMPORARY_PACKAGES='apt-transport-https wget gnupg ca-certificates software-properties-common lsb-release' && \
	apt-get update && \
	apt-get install --no-install-recommends -y $TEMPORARY_PACKAGES && \
	wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - && \
	apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -sc) main" && \
	apt-get update && \
	apt-get install --no-install-recommends -y \
		g++ cmake ninja-build \
		qtdeclarative5-dev libqt5charts5-dev && \
	apt-get autoremove $TEMPORARY_PACKAGES -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /src
