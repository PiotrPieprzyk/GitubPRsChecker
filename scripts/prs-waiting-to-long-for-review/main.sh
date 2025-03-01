#!/bin/bash

echo "$CLI_TOKEN" | gh auth login --with-token 

/scripts/fetch.sh | /scripts/generate-summary.sh >> $GITHUB_OUTPUT
