FROM jenkins/agent:latest-jdk17

USER root

RUN apt-get update && \
    apt-get install -y docker.io openssh-server openjdk-17-jdk && \
    mkdir /var/run/sshd && \
    rm -rf /var/lib/apt/lists/*

RUN echo "jenkins:jenkins" | chpasswd && \
    usermod -aG docker jenkins

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]