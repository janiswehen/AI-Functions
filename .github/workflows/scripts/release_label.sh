#!/bin/bash

source .github/workflows/scripts/github_utils.sh

# Define the release label
release_label="Release"
release_label_json="[\"$release_label\"]"

# Apply the release label to the PR
apply_labels_to_issue_or_pr "$GITHUB_TOKEN" "$GITHUB_REPOSITORY" "$PR_NUMBER" "$release_label_json" || exit 0

# Extract the issue number based on the branch name
issue_number=$(get_issue_number "$BRANCH_NAME") || exit 0

# If you also want to apply the label to the associated issue:
apply_labels_to_issue_or_pr "$GITHUB_TOKEN" "$GITHUB_REPOSITORY" "$issue_number" "$release_label_json" || exit 0
