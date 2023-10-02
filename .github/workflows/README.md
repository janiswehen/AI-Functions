## GitHub Workflows

Our repository employs two primary categories of GitHub Actions workflows: 

1. **Continuous Integration (CI) Workflows**: These workflows are responsible for building, testing, and validating the codebase.
2. **GitHub Automations**: Prefixed by `ga_`, these workflows are designed to automate various GitHub-related tasks, enhancing the efficiency of our repository management.

### GitHub Automation Workflows:

1. **`ga_issue_in_progress.yml`**: 
    - **Function**: Automatically moves an issue to the `In Progress` column on the project board.
    - **Trigger**: When a new branch is created with the issue number as its prefix.
  
2. **`ga_pr_status.yml`**:
    - **Function**: Assigns a pull request (PR) to either the `Development` or `Ready for Review` column based on its status.
    - **Trigger**: Based on whether the PR is a draft or ready for review.

3. **`ga_release_labeler.yml`**:
    - **Function**: Adds a `Release` label to a PR, and its associated issue if it exists.
    - **Trigger**: When a PR is created with the `release` branch as its base.

4. **`ga_label_transfer.yml`**:
    - **Function**: Copies labels from an issue to its corresponding PR when that PR is created.
    - **Trigger**: Creation of a PR that references an existing issue.

Please refer to the individual workflow files for more specific details on their operations and configurations.