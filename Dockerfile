# To run this Dockerfile, use the following command
# docker build -t github-prs-checker .          to build the image
# docker run -it github-prs-checker             to run the container
#  -t flag                to name the image as github-prs-checker
#  -it flag               to run the container in interactive mode


# Use the official Ubuntu base image
FROM ubuntu:latest


# apt-get update            to update the package list
#   -y flag                     to assume yes as the answer to all prompts and run non-interactively
RUN apt-get update && \
    apt-get install -y


# Install github cli
# Installing on linux https://github.com/cli/cli/blob/trunk/docs/install_linux.md

# type                  to check if a command is available in the shell, 
#   -p flag                 returns the path of the command
# apt update            to update the package list
# apt-get               install  to install the wget package
# mkdir                 to create a directory
#   -p flag                 to create the parent directories
#   -m flag                 to set permissions
# mktemp                to create a temporary file, returns the path of the file
# wget                  to download the file from the given url 
#   -O flag                 to specify the output file
#   -nv flag                to disable the output
# cat                   print file to the standard output
# tee                   to read from standard input and write to standard output and files
# chmod                 to change the file mode bits
#   go+r                    to give read permission to group and others

RUN (type -p wget >/dev/null || (apt update && apt-get install wget -y)) \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

# Get the github token from the file and login
COPY github-token.txt ./github-token.txt
RUN gh auth login --with-token < ./github-token.txt

# Copy scripts to the container \
COPY ./scripts /scripts

# Make the scripts executable
RUN chmod +x ./scripts/fetch-prs.sh ./scripts/generate-prs-summary.sh

# Run fetch-prs.sh script and pipe the output to generate-prs-summary.sh
RUN ./scripts/fetch-prs.sh | ./scripts/generate-prs-summary.sh
