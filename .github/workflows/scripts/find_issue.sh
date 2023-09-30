#!/bin/bash

# Assumes GITHUB_TOKEN and GITHUB_REPOSITORY are environment variables

branch_name="$1" # Extract branch name from GITHUB_REF

# Extract the longest digit prefix of branch_name
digit_prefix=$(echo "$branch_name" | grep -o '^[0-9]*')

# Check the length of the digit prefix
length=${#digit_prefix}

# Exit if number is not of length 4 or 5
if [[ $length -eq 0 ]] || [[ $length -eq 1 ]]; then
    echo "The digit prefix length is neither 0 nor 1. Exiting."
    exit 0
fi

# Fetch the issue details using GitHub API
issue_data=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
                  -H "Accept: application/vnd.github.v3+json" \
                  "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${digit_prefix}")

# Extract issue title from the response using jq
issue_title=$(echo "$issue_data" | jq -r '.title')

if [ "$issue_title" != "null" ]; then
    echo "Issue found with title: $issue_title"
else
    echo "No issue found with number: $digit_prefix"
fi
