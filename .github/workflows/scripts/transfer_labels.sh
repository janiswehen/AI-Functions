#!/bin/bash

source .github/workflows/scripts/github_utils.sh

issue_number=$(get_issue_number "$BRANCH_NAME")

# Exit if no valid issue number found
if [[ -z "$issue_number" ]]; then
    echo "No valid issue number found in branch name. Exiting." >&2
    exit 0
fi

labels_json=$(get_labels_to_issue_or_pr "$GITHUB_TOKEN" "$GITHUB_REPOSITORY" "$issue_number")

# Check if labels_json is empty (No labels found scenario)
if [[ -z "$labels_json" || "$labels_json" == "[]" ]]; then
    echo "No labels to transfer. Exiting." >&2
    exit 0
fi

apply_labels_to_issue_or_pr "$GITHUB_TOKEN" "$GITHUB_REPOSITORY" "$PR_NUMBER" "$labels_json"
