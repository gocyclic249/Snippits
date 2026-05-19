# Sync to GitLab

## Prerequisites

A blank target project must already exist on `web.git.mil` before this workflow will work — the mirror push won't create one for you. The project name on GitLab does **not** need to match the GitHub repo name; the workflow only follows the URL you save in `GITLAB_REPO_URL` (step 2 below).

## 1. Save `GITLAB_TOKEN` with Repo Write Permissions in Secrets

## 2. Save `GITLAB_REPO_URL` in Secrets in the format `web.git.mil/User/Project.git`

## 3. Create a file called `.github/workflows/mirror.yml` in github with the following code

```yaml
name: Mirror to GitLab

on:
  push:
    branches:
      - main
  delete:

jobs:
  mirror:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Push to GitLab
        run: |
          git push --prune https://oauth2:${{ secrets.GITLAB_TOKEN }}@${{ secrets.GITLAB_REPO_URL }} \
            "+refs/heads/*:refs/heads/*" \
            "+refs/tags/*:refs/tags/*"
```

## Common errors

- **`You are not allowed to force push code to a protected branch on this project`** — the destination branch on GitLab is protected and is rejecting the mirror's force-push. The workflow always force-pushes (the `+` prefix in `+refs/heads/*`) because that's how it stays a true mirror of GitHub even when histories diverge or branches are rewound. Fix it in the GitLab project: **Settings → Repository → Protected branches**, then explicitly authorize force push on the affected branch(es). This is by far the most common failure mode.
