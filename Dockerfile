FROM ubuntu:latest
# Install Ubuntu repository dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y xvfb xdotool gpg curl imagemagick x11-apps i3

#TO DEBUG: REMOVE
RUN apt install -y xterm

# Install Windsurf
RUN curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | \
    gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] \
    https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | \
    tee /etc/apt/sources.list.d/windsurf.list > /dev/null
RUN apt update
RUN apt install -y windsurf


# Cleanup packages installation artifacts
RUN apt clean && \
    rm -rf /var/lib/apt/lists/*

# Prepare and configure entrypoint
COPY src/scripts/entrypoint.sh /entrypoint.sh
RUN chmod ugo+x /entrypoint.sh

# General configuration
USER ubuntu:ubuntu
RUN mkdir /home/ubuntu/workspace
RUN chmod ugo+rwx -R /home/ubuntu/workspace
RUN chown ubuntu:ubuntu -R /home/ubuntu/workspace

# Prepare resource files
COPY --chown=ubuntu src/workflows/entry-workflow.md /home/ubuntu/entry-workflow.md
#RUN mkdir -p /home/ubuntu/.config/Windsurf/User/globalStorage
#COPY --chown=ubuntu:ubuntu src/config/state.vscdb /home/ubuntu/.config/Windsurf/User/globalStorage/state.vscdb
RUN mkdir -p /home/ubuntu/.config/i3
COPY --chown=ubuntu:ubuntu src/config/i3.conf /home/ubuntu/.config/i3/config 

CMD ["/entrypoint.sh"]