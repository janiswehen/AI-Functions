#!/bin/bash

source .github/workflows/scripts/github_utils.sh

# Extract the issue number based on the branch name
issue_number=$(get_issue_number "$BRANCH_NAME") || exit 0

# Get assignees associated with the issue number
assignees_json=$(get_assignees_to_issue_or_pr "$GITHUB_TOKEN" "$GITHUB_REPOSITORY" "$issue_number") || exit 0

echo "$assignees_json"

# Apply those assignees to the PR
apply_assignees_to_issue_or_pr "$GITHUB_TOKEN" "$GITHUB_REPOSITORY" "$PR_NUMBER" "$assignees_json" || exit 0
