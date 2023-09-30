#!/bin/bash

branch_name="$1" # The first argument is the branch name

# Extract the longest digit prefix of branch_name
digit_prefix=$(echo "$branch_name" | grep -o '^[0-9]*')

# Check the length of the digit prefix
length=${#digit_prefix}

# Exit if number is of length 0 or 1
if [[ $length -eq 0 ]] && [[ $length -eq 1 ]]; then
    echo "The digit prefix length is 0 nor 1. Exiting."
    exit 0
fi

# Fetch the issue details using GitHub API
issue_data=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
                  -H "Accept: application/vnd.github.v3+json" \
                  "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${digit_prefix}")

# Check if issue exists
issue_title=$(echo "$issue_data" | jq -r '.title')

if [ "$issue_title" == "null" ]; then
    echo "No issue found with number: $digit_prefix"
    exit 0
else
    echo "Issue found with title: $issue_title"
fi

# Extract issue labels with jq
labels_json=$(echo "$issue_data" | jq '.labels[] .name')
echo labels_json

# Apply the labels to the pull request
pr_number=$(echo "${GITHUB_REF##*/}" | grep -oE '[0-9]+')
echo pr_number
response=$(curl -s -X PUT \
               -H "Authorization: token ${GITHUB_TOKEN}" \
               -H "Accept: application/vnd.github.v3+json" \
               -d "{\"labels\": $labels_json}" \
               "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${pr_number}")

# Check if labels were applied successfully using jq
if [[ $(echo "$response" | jq '.labels') ]]; then
    echo "Labels applied to PR successfully."
else
    echo "Failed to apply labels to PR."
    exit 1
fi
