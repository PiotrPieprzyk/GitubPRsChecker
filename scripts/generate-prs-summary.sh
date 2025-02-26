#!/bin/bash

# Generate Summary for PRs that are waiting to long for the review

# Preconditions:
# Pass json with PRs info as an standard input

# Descriptions:
#
#
#

# Types definitions
# @typedef {PR[]} PRS
 
# @typedef {Object} PR
# @property {Date} createdAt
# @property {string} title
# @property {string} url
# @property {ReviewRequest[]} reviewRequests

# @typedef {Object} ReviewRequest
# @property {string} name - name of the reviewer
# @property {'User'} type - type of the reviewer

# Read the input from the pipe into the PRS variable
PRS=$(cat)
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SUMMARY="PR Review Summary:\n\n"

# Use process substitution to avoid subshell issues
while read -r PR; do
  TITLE=$(echo "$PR" | jq -r '.title')
  URL=$(echo "$PR" | jq -r '.url')
  REVIEWERS=$(echo "$PR" | jq -r '.reviewRequests[].name')
  CREATED_AT=$(echo "$PR" | jq -r '.createdAt')
  WAIT_TIME=$(($(date -d "$NOW" +%s) - $(date -d "$CREATED_AT" +%s)))
  WAIT_DAYS=$((WAIT_TIME / 86400))

  SUMMARY+="----------\n"
  SUMMARY+="Name: $TITLE\n"
  SUMMARY+="Link: $URL\n"
  SUMMARY+="Waiting time: ${WAIT_DAYS} days\n"
  SUMMARY+="Waiting for:\n"
  for REVIEWER in $REVIEWERS; do
    SUMMARY+="- $REVIEWER\n"
  done
  SUMMARY+="\n"
  
done < <(echo "$PRS" | jq -c '.[]')

echo -e "$SUMMARY"
