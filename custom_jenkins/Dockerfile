# Custom Jenkins Dockerfile for MLOps with enhanced capabilities
# Uses Jenkins LTS as base with added Docker, Python, and MLOps tools

FROM jenkins/jenkins:lts

# Labels for better image management
LABEL maintainer="Abul Faiz Bangi"
LABEL description="Custom Jenkins image for MLOps pipelines with Docker support"
LABEL version="1.0"

# Switch to root for installations
USER root

# Install essential tools with pinned versions and clean up in single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      software-properties-common \
      docker.io \
      containerd \
      unzip \
      git \
      python3 \
      python3-pip \
      python3-venv \
      jq \
      vim \
      wget \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && pip3 install --no-cache-dir virtualenv

# Add Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
      && chmod +x /usr/local/bin/docker-compose

# Install uv - Python package manager (with version)
RUN curl -Ls https://astral.sh/uv/install.sh | bash -s -- --version 0.1.20
ENV PATH="/root/.cargo/bin:${PATH}"

# Create Python virtual environment for Jenkins
RUN python3 -m venv /opt/jenkins_python \
      && /opt/jenkins_python/bin/pip install --no-cache-dir --upgrade pip \
      && /opt/jenkins_python/bin/pip install --no-cache-dir pytest pytest-cov black isort flake8

# Configure Docker group and permissions
RUN groupadd -f docker \
      && usermod -aG docker jenkins \
      && mkdir -p /var/lib/docker \
      && chown -R root:docker /var/lib/docker \
      && chmod -R 770 /var/lib/docker

# Create directory for Jenkins data with proper permissions
RUN mkdir -p /var/jenkins_data \
      && chown -R jenkins:jenkins /var/jenkins_data \
      && chmod -R 755 /var/jenkins_data

# Create shared space for MLOps artifacts
RUN mkdir -p /opt/mlops_artifacts \
      && chown -R jenkins:jenkins /opt/mlops_artifacts \
      && chmod -R 755 /opt/mlops_artifacts

# Create a script to fix permissions on startup
COPY <<'EOF' /usr/local/bin/jenkins-setup.sh
#!/bin/bash
# This script runs on container startup to ensure proper permissions

# Ensure Docker socket has correct permissions if mounted
if [ -S /var/run/docker.sock ]; then
      DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
      if [ "$DOCKER_GID" != "0" ]; then
      # If docker socket group ID is not root (0)
      if ! getent group $DOCKER_GID > /dev/null 2>&1; then
      # Create a new group with the same GID as the docker socket
      groupadd -g $DOCKER_GID docker-external
      fi
      # Add jenkins user to this group
      usermod -aG $DOCKER_GID jenkins
      fi
fi

# Set up Python environment variables for Jenkins user
echo "export PATH=/opt/jenkins_python/bin:${PATH}" >> /var/jenkins_home/.bashrc
echo "export PYTHONPATH=/var/jenkins_home/workspace" >> /var/jenkins_home/.bashrc

# Continue with regular Jenkins entrypoint
exec /sbin/tini -- /usr/local/bin/jenkins.sh "$@"
EOF

RUN chmod +x /usr/local/bin/jenkins-setup.sh

# Volumes for persistent data
VOLUME ["/var/jenkins_home", "/var/jenkins_data", "/var/lib/docker", "/opt/mlops_artifacts"]

# Expose additional ports if needed (e.g., for your Flask app)
EXPOSE 8080 50000 5000

# Switch back to Jenkins user for better security
USER jenkins

# Set up environment variables for Jenkins
ENV JENKINS_HOME="/var/jenkins_home" \
      JENKINS_OPTS="--prefix=/jenkins" \
      JENKINS_JAVA_OPTS="-Djava.awt.headless=true -Djenkins.install.runSetupWizard=true" \
      PATH="/opt/jenkins_python/bin:${PATH}" \
      PYTHONPATH="/var/jenkins_home/workspace"

# Use our custom setup script as entrypoint
ENTRYPOINT ["/usr/local/bin/jenkins-setup.sh"]