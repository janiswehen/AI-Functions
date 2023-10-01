#!/bin/bash

source .github/workflows/scripts/github_utils.sh

issue_number=$(get_issue_number)
labels_json=$(get_labels_to_issue_or_pr "$issue_number")
apply_labels_to_issue_or_pr "$PR_NUMBER" "$labels_json"
