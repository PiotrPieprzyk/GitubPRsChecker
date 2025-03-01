#!/bin/bash

echo "$github_token" | gh auth login --with-token 

/scripts/fetch.sh | /scripts/generate-summary.sh >> $GITHUB_OUTPUT
