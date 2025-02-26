#!/bin/bash

# Script to fetch PRD that are waiting to long for the review

# Alternatives:
# You can use https://github.com/search with the following search parameter:
# - repo:EENCloud/WEB-VMS-WebApp repo:EENCloud/frontend-gui repo:EENCloud/WEB-EEWC-Components repo:EENCloud/WEB-Floor-Plan  type:pr author:PiotrPieprzyk author:piotrlatala author:ArekEvo author:aleksander-pisarek created:<2025-02-24T00:00:00Z draft:false state:open review:required
# Reference: https://docs.github.com/en/search-github/searching-on-github/searching-issues-and-pull-requests#search-within-a-users-or-organizations-repositories

# Description:
# PRS should be filtered by the following conditions:
# 	- review is required (review:required)
#   - PR is not closed (use state:open)
#   - PR is not draft (use draft:false)
#   - PR is older than 2 days (use created:<YYYY-MM-DDTHH:MM:SSZ)
#   - PR author is member of the web_1 team (use author:{Username} author:piotrlatala author:ArekEvo author:aleksander-pisarek ):
#     - PiotrPieprzyk
#     - piotrlatala
#     - ArekEvo
#     - aleksander-pisarek
#   - PR is from following repositories (use --repo {Repository name}):
#     - EENCloud/WEB-VMS-WebApp
#     - EENCloud/WEB-EEWC-Components
#     - EENCloud/frontend-gui
#     - EENCloud/WEB-Floor-Plan
# PRS should be passed to the standard output in the following format:
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

# search parameters
filter_created="created:<$(date -u -d "2 days ago" +"%Y-%m-%dT%H:%M:%SZ")"
filter_is_not_draft="draft:false"
filter_is_open="state:open"
filter_review_required="review:required"
filter_author="author:piotrlatala author:ArekEvo author:aleksander-pisarek author:PiotrPieprzyk"
search_query="$filter_created $filter_is_not_draft $filter_is_open $filter_review_required $filter_author"

getWaitingPRsByRepository() {
  local repo_name=$1
  gh pr list --json title,url,reviewRequests,createdAt --search "$search_query" --repo "$repo_name"
}

waiting_prs_WebApp=$(getWaitingPRsByRepository "EENCloud/WEB-VMS-WebApp")
waiting_prs_frontend_gui=$(getWaitingPRsByRepository "EENCloud/frontend-gui")
waiting_prs_WEB_EEWC_Components=$(getWaitingPRsByRepository "EENCloud/WEB-EEWC-Components")
waiting_prs_WEB_Floor_Plan=$(getWaitingPRsByRepository "EENCloud/WEB-Floor-Plan")

# Create one array with all PRs by flatting the arrays
all_PRS=$(echo "$waiting_prs_WebApp $waiting_prs_frontend_gui $waiting_prs_WEB_EEWC_Components $waiting_prs_WEB_Floor_Plan" | jq -c -s 'flatten(1)')

# Map PRs to the required format
mapReviewRequest() {
  local reviewer=$1
  local name=$(echo "$reviewer" | jq -r '.login')
  local type=$(echo "$reviewer" | jq -r '.__typename')
  echo "{\"name\":\"$name\",\"type\":\"$type\"}"
}

mapPr() {
  local PR=$1
  local title=$(echo "$PR" | jq -r '.title')
  local url=$(echo "$PR" | jq -r '.url')
  local createdAt=$(echo "$PR" | jq -r '.createdAt')
  local reviewRequestsArray=$(echo "$PR" | jq -c '.reviewRequests[]' | while read -r reviewer; do mapReviewRequest "$reviewer"; done)
  local reviewRequestsJSONArray=$(echo "$reviewRequestsArray" | jq -c -s '.')
  echo "{\"title\":\"$title\",\"url\":\"$url\",\"createdAt\":\"$createdAt\",\"reviewRequests\":$reviewRequestsJSONArray}"
}

all_PRS_MAPPED=$(echo "${all_PRS[@]}" | jq -c '.[]' | while read -r PR; do mapPr "$PR"; done | jq -c -s '.')

echo "${all_PRS_MAPPED[@]}"




