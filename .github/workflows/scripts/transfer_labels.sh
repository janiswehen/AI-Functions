#!/bin/bash

source .github/workflows/scripts/github_utils.sh

# Trap any errors from the helper script and exit gracefully
trap 'exit 0' ERR

# Extract the issue number based on the branch name
issue_number=$(get_issue_number "$BRANCH_NAME")

# Get labels associated with the issue number
labels_json=$(get_labels_to_issue_or_pr "$GITHUB_TOKEN" "$GITHUB_REPOSITORY" "$issue_number")

# Apply those labels to the PR
apply_labels_to_issue_or_pr "$GITHUB_TOKEN" "$GITHUB_REPOSITORY" "$PR_NUMBER" "$labels_json"
