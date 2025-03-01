# Github PRS Checker

## Goal 
The goal of this project is to create a tool that will automize process of reviewing open PRS.

## Table of contents
- [Technologies](#Technologies)
- [Features](#Features)
  - [Generate summary for prs that are waiting too long for review](#Generate-summary-for-prs-that-are-waiting-too-long-for-review)
    - [Advantages](#Advantages)
    - [Alternatives](#Alternatives)
    - [How to use](#How-to-use)

## Technologies:
- Bash
- GitHub CLI
- Github actions

### Generate summary for prs that are waiting too long for review

#### Advantages:
- Automize the process of fetching PRs, generating the summary, and sending it to the team

#### Alternatives:
You can use https://github.com/search with the following search parameter:
repo:EENCloud/WEB-VMS-WebApp repo:EENCloud/frontend-gui repo:EENCloud/WEB-EEWC-Components repo:EENCloud/WEB-Floor-Plan  type:pr author:PiotrPieprzyk author:piotrlatala author:ArekEvo author:aleksander-pisarek created:<2025-02-24T00:00:00Z draft:false state:open review:required
Reference: https://docs.github.com/en/search-github/searching-on-github/searching-issues-and-pull-requests#search-within-a-users-or-organizations-repositories

#### How to use:



