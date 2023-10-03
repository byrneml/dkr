# Use the gitpod/workspace-full:latest image as the base image
FROM gitpod/workspace-full:latest

# Switch to root user for installations
USER root

# Install various tools and libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    npm \
    apt-utils \
    clang \
    libavcodec-dev \
    libavformat-dev \
    libavfilter-dev \
    libavdevice-dev \
    libavutil-dev \
    libssl-dev \
    pkg-config \
    postgresql \
    libvulkan1 \
    libgl1 \
    libglib2.0-0 \
    wget \
    nvidia-cuda-toolkit \
    cuda-command-line-tools-11-0 \
    libcudnn8=8.0.4.30-1+cuda11.0 \
    libcudnn8-dev=8.0.4.30-1+cuda11.0 && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

# Download and install external packages
RUN wget https://github.com/Oxen-AI/Oxen/releases/download/v0.8.7/oxen-ubuntu-latest-0.8.7.deb && \
    dpkg -i oxen-ubuntu-latest-0.8.7.deb && \
    rm oxen-ubuntu-latest-0.8.7.deb && \
    wget https://github.com/Juice-Labs/Juice-Labs/releases/latest/download/JuiceClient-linux.tar.gz && \
    mkdir /JuiceClient && \
    mv JuiceClient-linux.tar.gz /JuiceClient && \
    cd /JuiceClient && \
    tar xvzf JuiceClient-linux.tar.gz && \
    chown -R gitpod /JuiceClient

# Set an environment variable for Juice Client
ENV JUICE_CFG_OVERRIDE '{"host": "100.108.145.17"}'

# Set up Tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | apt-key add - && \
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | tee /etc/apt/sources.list.d/tailscale.list && \
    apt-get update -q && \
    apt-get install -yq tailscale jq && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-nft && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Set the working directory
WORKDIR /workspace

# Copy the project files into the Docker image
COPY . /workspace

# Install project dependencies
RUN poetry config virtualenvs.create false && \
    poetry install

# Switch back to the gitpod user
USER gitpod
