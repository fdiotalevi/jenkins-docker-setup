# jenkins container with addons
#
# VERSION               0.2

FROM shimmi/jenkins:lts

ARG uid=1000

USER root
RUN chown ${uid} -R "$JENKINS_HOME"

# make sure the package repository is up to date
RUN apt-get update -q

# install sshpass
RUN apt-get -y install sshpass

# Install Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install
RUN apt-get -y install xvfb

# Install plugins, see https://github.com/jenkinsci/docker#preinstalling-plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
# tell jenkins that this Jenkins installation is fully configured. Otherwise a
# banner will appear prompting the user to install additional plugins, which may be inappropriate.
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
# drop back to the regular jenkins user - good practice
USER jenkins

# User
ENV JENKINS_USER admin
ENV JENKINS_PASS admin
# Increase docker timeout
ENV JAVA_OPTS -Dorg.jenkinsci.plugins.docker.workflow.client.DockerClient.CLIENT_TIMEOUT=600

COPY groovy_init/init.groovy /usr/share/jenkins/ref/init.groovy.d/init.groovy
COPY config/jenkins /usr/share/jenkins/ref/config
