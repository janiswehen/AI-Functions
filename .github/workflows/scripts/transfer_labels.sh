#!/bin/bash

# Extract the longest issue number of BRANCH_NAME
get_issue_number() {
    local issue_number
    issue_number=$(echo "$BRANCH_NAME" | grep -o '^[0-9]*')
    local length=${#issue_number}

    # Exit if the issue number length is 0 or 1
    if [[ $length -le 1 ]]; then
        echo "The digit prefix length is 0 or 1. Exiting." >&2
        exit 0
    else
        echo "Issue number: $issue_number" >&2
    fi

    echo "$issue_number"
}

# Fetch issue data using the GitHub API
fetch_issue_data() {
    local issue_number="$1"

    curl -s \
         -H "Authorization: token ${GITHUB_TOKEN}" \
         -H "Accept: application/vnd.github.v3+json" \
         "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${issue_number}"
}

get_labels_from_issue() {
    local issue_number="$1"
    local issue_data
    local issue_title
    local labels_json

    issue_data=$(fetch_issue_data "$issue_number")
    issue_title=$(echo "$issue_data" | jq -r '.title')

    # Check if the issue exists
    if [ "$issue_title" == "null" ]; then
        echo "No issue found with number: $issue_number" >&2
        exit 0
    fi

    echo "Issue found with title: $issue_title" >&2

    # Extract issue labels and format them into a JSON array
    labels_json=$(echo "$issue_data" | jq '.labels[] .name' | tr '\n' ',' | sed 's/,$//' | awk '{print "["$0"]"}')

    if [ "$labels_json" == "[]" ]; then
        echo "No labels found."
        exit 0
    fi

    echo "Extracted labels: $labels_json" >&2

    # Return the extracted labels in JSON format
    echo "$labels_json"
}

# Apply labels to a pull request using the GitHub API
apply_labels_to_issue() {
    local issue_number="$1"
    local labels_json="$2"
    
    local response
    local http_status

    response=$(curl -L \
                    -X POST \
                    -H "Accept: application/vnd.github+json" \
                    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                    https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${issue_number}/labels \
                    -d "{\"labels\":${labels_json}}" \
                    -w "\nHTTP_STATUS:%{http_code}\n" 2>&1)

    http_status=$(echo "$response" | grep "HTTP_STATUS" | awk -F: '{print $2}')

    # Check the API response status
    if [[ "$http_status" -ge 200 && "$http_status" -lt 300 ]]; then
        echo "Labels applied to PR successfully." >&2
    else
        echo "Failed to apply labels to PR." >&2
        exit 0
    fi
}

issue_number=$(get_issue_number)
labels_json=$(get_labels_from_issue "$issue_number")
apply_labels_to_issue "$PR_NUMBER" "$labels_json"
