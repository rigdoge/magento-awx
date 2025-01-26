ARG EE_BASE_IMAGE=quay.io/ansible/awx-ee:latest
FROM $EE_BASE_IMAGE

USER root

# Install additional packages
RUN pip3 install --upgrade pip setuptools
RUN pip3 install kubernetes

# Install collections
RUN ansible-galaxy collection install kubernetes.core

USER 1000 