# Use the Jenkins LTS image as the base image
# Maintained by the Jenkins project, includes the latest stable Jenkins
# Official: https://hub.docker.com/r/jenkins/jenkins
FROM jenkins/jenkins:lts 

# Switch to root to install packages
USER root

# Install Docker runtime from Debian repos (supports arm64 & bookworm)
# 1. Update package list
# 2. Install dependencies for apt over HTTPS
# 3. Install Docker (docker.io & containerd)
# 4. Clean up to reduce image size
RUN apt-get update -y && \
      apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      software-properties-common && \
      # Use Docker package provided by Debian
      apt-get install -y docker.io containerd && \
      rm -rf /var/lib/apt/lists/*

# Ensure Docker group exists and add Jenkins user to it
# So Jenkins can run Docker commands without sudo
RUN groupadd -f docker && \
      usermod -aG docker jenkins

# Prepare Docker-in-Docker (DinD) data directory
# and persist it across container restarts
RUN mkdir -p /var/lib/docker
VOLUME /var/lib/docker

# Revert to the Jenkins user for security
USER jenkins