# Github PRS Checker

## Goal

The goal of this project is to create a tool that will automize process of reviewing open PRS.

## Table of contents

- [Technologies](#Technologies)
- [Scripts](#Scripts)
    - [Generate summary for prs that are waiting too long for review](#Generate-summary-for-prs-that-are-waiting-too-long-for-review)
        - [Advantages](#Advantages)
        - [Alternatives](#Alternatives)
        - [How to test](#how-to-test)

## Technologies:

- Bash - to run the logic
- GitHub CLI - to fetch PRs
- Github actions - to automize the process and run in the cloud
- Docker - to test and run it easily on isolated environments

## Scripts:

### Generate summary for prs that are waiting too long for review

#### Description:

This script fetches all PRs that are waiting too long for review and generates a summary that is sent to the team.

TODO: The summary should be send to chosen Zulip stream or email.

#### Advantages:

- Automize the process of fetching PRs, generating the summary, and sending it to the team

#### Alternatives:

You can use https://github.com/search with the following search parameter:

```
repo:EENCloud/WEB-VMS-WebApp repo:EENCloud/frontend-gui repo:EENCloud/WEB-EEWC-Components repo:EENCloud/WEB-Floor-Plan  type:pr author:PiotrPieprzyk author:piotrlatala author:ArekEvo author:aleksander-pisarek created:<2025-02-24T00:00:00Z draft:false state:open review:required
```

Reference: https://docs.github.com/en/search-github/searching-on-github/searching-issues-and-pull-requests#search-within-a-users-or-organizations-repositories

#### How to set up github action:

1. Create secret CLI_TOKEN in the repository settings with a classic token with the following permissions:
    - repo
    - read:org
    - gist
2. Create github action in the .github/workflows directory with the following content:

```yaml
name: PRS Checker | PRs waiting to long for review

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  prs-waiting-to-long-for-review:
    uses: PiotrPieprzyk/GitubPRsChecker/./.github/workflows/prs-waiting-to-long-for-review-reusable.yml
    secrets:
      CLI_TOKEN: ${{ secrets.CLI_TOKEN }}
    with:
      authors: 'piotrlatala ArekEvo aleksander-pisarek PiotrPieprzyk'
      repositories: 'EENCloud/WEB-VMS-WebApp EENCloud/frontend-gui EENCloud/WEB-EEWC-Components EENCloud/WEB-Floor-Plan'
      days: '2'
```

#### How to test:

1. To test this script you need to have a github-token.txt file in the root directory of the repository
   The file should contain a classic token with the following permissions:
    - repo
    - read:org
    - gist

2. Give execution permissions to the test.sh file:

```bash
sudo chmod +x ./scripts/prs-waiting-to-long-for-review/test.sh
```

3. Run the test.sh file:

```bash
./scripts/prs-waiting-to-long-for-review/test.sh
```
