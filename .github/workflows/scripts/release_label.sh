#!/bin/bash

echo "$BASE_REF $BASE_LABEL"
exit 0

# Extract the longest digit prefix of BRANCH_NAME
digit_prefix=$(echo "$BRANCH_NAME" | grep -o '^[0-9]*')

# Check the length of the digit prefix
length=${#digit_prefix}

# Exit if number is of length 0 or 1
if [[ $length -eq 0 ]] || [[ $length -eq 1 ]]; then
    echo "The digit prefix length is 0 or 1. Exiting."
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

# Extract issue labels with jq and transform them into a JSON array format
labels_json=$(echo "$issue_data" | jq '.labels[] .name' | tr '\n' ',' | sed 's/,$//' | awk '{print "["$0"]"}')
if [ "$labels_json" == "" ]; then
    echo "No labels found."
    exit 0
else
    echo "Extracted labels: $labels_json"
fi

# Apply the labels to the pull request
response=$(curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${PR_NUMBER}/labels \
    -d "{\"labels\":$labels_json}" \
    -w "\nHTTP_STATUS:%{http_code}\n" 2>&1)

echo "Response from GitHub API:"
echo "$response"

http_status=$(echo "$response" | grep "HTTP_STATUS" | awk -F: '{print $2}')
if [[ "$http_status" -ge 200 && "$http_status" -lt 300 ]]; then
    echo "Labels applied to PR successfully."
else
    echo "Failed to apply labels to PR."
    exit 0
fi
