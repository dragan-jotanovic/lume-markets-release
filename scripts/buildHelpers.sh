#!/bin/bash
# Set of utility functions

gitSetup() {
    GIT_EMAIL="${GIT_EMAIL:-support@lucera.com}"
    GIT_USERNAME="${GIT_USERNAME:-Teamcity}"
    
    if [[ -z $GITHUB_TOKEN ]]; then
        echo "Error: GITHUB_TOKEN environment variable is not set."
        exit 1
    fi
    
    # Configure git with provided user details
    git config --global user.email "${GIT_EMAIL}"
    git config --global user.name "${GIT_USERNAME}"
    git config --global --add safe.directory "$(pwd)"
}

gitCheckout() {
    local REPO_NAME=$1
    local BRANCH=$2
    
    mkdir -p checkouts/$REPO_NAME
    cd checkouts/$REPO_NAME
    
    if [ ! -d "./.git" ]; then
        REPO_PREFIX_WITH_USER=$(echo "$REPO_PREFIX" | sed "s/github.com/${GIT_USERNAME}@github.com/")
        echo "Cloning ${REPO_PREFIX_WITH_USER}${REPO_NAME} to $(pwd)"
        git clone ${REPO_PREFIX_WITH_USER}${REPO_NAME} .
        git config user.email "${GIT_EMAIL}"
        git config user.name "${GIT_USERNAME}"
        git config credential.helper '!f() { echo username=${GIT_USERNAME}; echo "password=$GITHUB_TOKEN"; };f'
        git config --global --add safe.directory "$(pwd)"
    fi
    if [[ "$BRANCH" ]]; then
        echo "Checking out branch: ${BRANCH}"
        git checkout $BRANCH
    fi
    git reset --hard HEAD
    git pull
    cd ../..
}

# Function to commit and push changes to a git repository using provided credentials.
gitCommitAndPush() {
    local REPO_NAME=$1
    local COMMIT_MESSAGE=$2
    
    if [ -n "$(git status --porcelain)" ]; then
        git add -A
        git commit -m "${COMMIT_MESSAGE}"
        REPO_PREFIX_WITH_USER=$(echo "$REPO_PREFIX" | sed "s/github.com/${GIT_USERNAME}@github.com/")
        git push ${REPO_PREFIX_WITH_USER}${REPO_NAME}
    else
      echo "There were no changes, nothing to commit!";
    fi
}
