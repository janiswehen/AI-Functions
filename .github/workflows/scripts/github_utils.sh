#!/bin/bash

set -e

# Extract the longest issue number from BRANCH_NAME
get_issue_number() {
    local branch_name="$1"

    local issue_number
    issue_number=$(echo "$branch_name" | grep -o '^[0-9]*')
    local length=${#issue_number}

    # If the issue number length is 0 or 1, return an error
    if [[ $length -le 1 ]]; then
        echo "Error: No valid issue number found in branch name." >&2
        exit 1
    else
        echo "Issue number: $issue_number" >&2
    fi

    echo "$issue_number"
}

# Add labels to an issue or PR using the GitHub API
apply_labels_to_issue_or_pr() {
    local github_token="$1"
    local repo_name="$2"
    local issue_number="$3"
    local labels_json="$4"

    local response
    local http_status

    response=$(curl -L \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${github_token}" \
        https://api.github.com/repos/${repo_name}/issues/${issue_number}/labels \
        -d "{\"labels\":${labels_json}}" \
        -w "\nHTTP_STATUS:%{http_code}\n" 2>&1)

    http_status=$(echo "$response" | grep "HTTP_STATUS" | awk -F: '{print $2}')

    # Check the API response status and exit if there's an error
    if [[ "$http_status" -ge 200 && "$http_status" -lt 300 ]]; then
        echo "Labels applied to PR successfully." >&2
    else
        echo "Error: Failed to apply labels to PR." >&2
        exit 1
    fi
}

# Add assignees to an issue or PR using the GitHub API
apply_assignees_to_issue_or_pr() {
    local github_token="$1"
    local repo_name="$2"
    local issue_number="$3"
    local assignees_json="$4"

    local response
    local http_status

    response=$(curl -L \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${github_token}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/${repo_name}/issues/${issue_number}/assignees \
        -d "{\"assignees\":${assignees_json}}" \
        -w "\nHTTP_STATUS:%{http_code}\n" 2>&1)

    http_status=$(echo "$response" | grep "HTTP_STATUS" | awk -F: '{print $2}')

    # Check the API response status and exit if there's an error
    if [[ "$http_status" -ge 200 && "$http_status" -lt 300 ]]; then
        echo "Assignees applied to PR successfully." >&2
    else
        echo "Error: Failed to apply assignees to PR." >&2
        exit 1
    fi
}

# Gets labels to an issue or PR using the GitHub API
get_labels_to_issue_or_pr() {
    local github_token="$1"
    local repo_name="$2"
    local issue_number="$3"

    local issue_data
    local issue_title
    local labels_json

    issue_data=$(curl -s \
        -H "Authorization: token ${github_token}" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/${repo_name}/issues/${issue_number}")

    issue_title=$(echo "$issue_data" | jq -r '.title')

    # Check if the issue exists and exit if not found
    if [ "$issue_title" == "null" ]; then
        echo "Error: No issue found with number: $issue_number" >&2
        exit 1
    fi
    echo "Issue found with title: $issue_title" >&2

    # Extract issue labels and format them into a JSON array
    labels_json=$(echo "$issue_data" | jq '.labels[] .name' | tr '\n' ',' | sed 's/,$//' | awk '{print "["$0"]"}')

    # Exit if no labels are found
    if [ "$labels_json" == "" ]; then
        echo "Error: No labels found." >&2
        exit 1
    fi

    echo "Extracted labels: $labels_json" >&2

    # Return the extracted labels in JSON format
    echo "$labels_json"
}

# Gets assignees of an issue or PR using the GitHub API
get_assignees_to_issue_or_pr() {
    local github_token="$1"
    local repo_name="$2"
    local issue_number="$3"

    local issue_data
    local issue_title
    local assignees_json

    issue_data=$(curl -s \
        -H "Authorization: token ${github_token}" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/${repo_name}/issues/${issue_number}")

    issue_title=$(echo "$issue_data" | jq -r '.title')

    # Check if the issue exists and exit if not found
    if [ "$issue_title" == "null" ]; then
        echo "Error: No issue found with number: $issue_number" >&2
        exit 1
    fi
    echo "Issue found with title: $issue_title" >&2

    # Extract issue assignees and format them into a JSON array
    assignees_json=$(echo "$issue_data" | jq '.assignees[] .login' | tr '\n' ',' | sed 's/,$//' | awk '{print "["$0"]"}')

    # Exit if no assignees are found
    if [ "$assignees_json" == "[]" ]; then
        echo "Error: No assignees found." >&2
        exit 1
    fi

    echo "Extracted assignees: $assignees_json" >&2

    # Return the extracted assignees in JSON format
    echo "$assignees_json"
}
