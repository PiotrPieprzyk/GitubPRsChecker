#!/bin/bash

# Script to fetch PRD that are waiting to long for the review

# Alternatives:
# You can use https://github.com/search with the following search parameter:
# - repo:EENCloud/WEB-VMS-WebApp repo:EENCloud/frontend-gui repo:EENCloud/WEB-EEWC-Components repo:EENCloud/WEB-Floor-Plan  type:pr author:PiotrPieprzyk author:piotrlatala author:ArekEvo author:aleksander-pisarek created:<2025-02-24T00:00:00Z draft:false state:open review:required
# Reference: https://docs.github.com/en/search-github/searching-on-github/searching-issues-and-pull-requests#search-within-a-users-or-organizations-repositories

# Description:
# PRS should be filtered by the following conditions:
# 	- review is required 
#   - PR is not closed 
#   - PR is not draft
#   - PR is older than number of days passed as a parameter
#   - PR author is one of passed as a parameter
#   - PR is from repositories passed as a parameter
# PRS should be passed to the standard output in the following format: PRS

# Parameters
# -r - repositories to filter PRs. You can pass multiple repositories separated by comas
# -a - authors to filter PRs. You can pass multiple authors separated by comas
# -d - number of days after which PR is considered as waiting too long for the review

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

filter_repositories_default="EENCloud/WEB-VMS-WebApp EENCloud/frontend-gui EENCloud/WEB-EEWC-Components EENCloud/WEB-Floor-Plan"

filter_author_default="piotrlatala ArekEvo aleksander-pisarek PiotrPieprzyk"

filter_days_default=2

# Get parameters
while getopts "r:a:d:" opt; do
  case $opt in
    r) filter_repositories_parameter="$OPTARG";;
    a) filter_author_parameter="$OPTARG";;
    d) filter_days_parameter="$OPTARG";;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# repositories in filter_repositories_parameter are split by comas. Replace comas with spaces
filter_repositories="${filter_repositories_parameter//,/ }"
if [ -z "$filter_repositories" ]; then
  filter_repositories="$filter_repositories_default"
fi

filter_author="${filter_author_parameter//,/ }"
if [ -z "$filter_author" ]; then
  filter_author="$filter_author_default"
fi

filter_days="$filter_days_parameter"
if [ -z "$filter_days_parameter" ]; then
  filter_days="$filter_days_default"
fi

# FETCH RESULTS

# To filter_author items we need to add prefix "author:". Each author is separated by space
filter_author_mapped=$(echo $filter_author | sed 's/\(\w\+\)/author:\1/g')
filter_created="created:<$(date -u -d "$filter_days days ago" +"%Y-%m-%dT%H:%M:%SZ")"
filter_is_not_draft="draft:false"
filter_is_open="state:open"
filter_review_required="review:required"
search_query="$filter_created $filter_is_not_draft $filter_is_open $filter_review_required $filter_author_mapped"

getWaitingPRsByRepository() {
  local repo_name
  repo_name=$1
  gh pr list --json title,url,reviewRequests,createdAt --search "$search_query" --repo "$repo_name"
}

prsForRepositories=()
for repo in $filter_repositories;
do
  prsForRepositories+=("$(getWaitingPRsByRepository "$repo")")
  if [ $? -ne 0 ]; 
  then
    echo "Error during fetching PRs for repository: $repo"
    exit 1
  fi
done

# FLAT RESULTS
prsForRepositoriesFlat=$(echo "${prsForRepositories[@]}" | jq -c '.[]')

# MAP RESULTS
mapReviewRequestsRule="{
  name:.login, 
  type:.__typename
}"

mapPrRule="{
  title:.title, 
  url:.url, 
  createdAt:.createdAt, 
  reviewRequests: [
    .reviewRequests[] | $mapReviewRequestsRule
  ]
}"

mapPrs() {
  echo "$1" | jq -c "$mapPrRule" | jq -s
}

prsForRepositoriesMapped=$(mapPrs "${prsForRepositoriesFlat[@]}")
if [ $? -ne 0 ]; then
  echo "Error during mapping results"
  exit 1
fi

echo "${prsForRepositoriesMapped[@]}"




