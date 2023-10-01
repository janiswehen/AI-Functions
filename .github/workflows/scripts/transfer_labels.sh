#!/bin/bash

source .github/workflows/scripts/github_utils.sh

# Extract the issue number based on the branch name
issue_number=$(get_issue_number "$BRANCH_NAME") || exit 0

# Get labels associated with the issue number
labels_json=$(get_labels_to_issue_or_pr "$GITHUB_TOKEN" "$GITHUB_REPOSITORY" "$issue_number") || exit 0

# Apply those labels to the PR
apply_labels_to_issue_or_pr "$GITHUB_TOKEN" "$GITHUB_REPOSITORY" "$PR_NUMBER" "$labels_json" || exit 0
