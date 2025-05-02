# Use the Jenkins LTS image as the base image
FROM jenkins/jenkins:lts

# Switch to root to install packages
USER root

# Install Docker runtime and necessary tools
RUN apt-get update -y && \
      apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      software-properties-common \
      docker.io \
      containerd \
      unzip && \
      rm -rf /var/lib/apt/lists/*

# Ensure Docker group exists and add Jenkins user to it
RUN groupadd -f docker && \
      usermod -aG docker jenkins

# Prepare Docker-in-Docker (DinD) data directory
RUN mkdir -p /var/lib/docker
VOLUME /var/lib/docker

# Install uv - Python package manager
RUN curl -Ls https://astral.sh/uv/install.sh | bash

# Ensure uv is available in the path
ENV PATH="/root/.cargo/bin:$PATH"

# Revert to Jenkins user
USER jenkins
