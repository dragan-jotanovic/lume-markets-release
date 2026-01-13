#!/bin/bash
# Set of utility functions

readVersion() {
  local version=$(cat VERSION)
  echo $version
}

incrementVersionNumber() {
  local version=$1
  IFS=. read -r major minor patch <<<"$version"
  ((patch++))
  echo "${major}.${minor}.${patch}"
}

decrementVersionNumber() {
  local version=$1
  previousVersion=$(echo ${version} | awk -F. -v OFS=. '{$NF -= 1 ; print}')
  echo $previousVersion
}

getNextMinorVersion() {
  local version=$1
  IFS=. read -r major minor patch <<<"$version"
  ((minor++))
  echo "${major}.${minor}.0"
}

getReleaseVersion() {
  local version=$1
  IFS=. read -r major minor patch <<<"$version"
  echo "${major}.${minor}"
}

updateVersion() {
  local version=$1
  echo "${version}" >VERSION
}

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

    git config --global --add safe.directory "$(pwd)"
    if [ ! -d "./.git" ]; then
        REPO_PREFIX_WITH_USER=$(echo "$REPO_PREFIX" | sed "s/github.com/${GIT_USERNAME}@github.com/")
        echo "Cloning ${REPO_PREFIX_WITH_USER}${REPO_NAME} to $(pwd)"
        git clone ${REPO_PREFIX_WITH_USER}${REPO_NAME} .
        git config user.email "${GIT_EMAIL}"
        git config user.name "${GIT_USERNAME}"
        git config credential.helper '!f() { echo username=${GIT_USERNAME}; echo "password=$GITHUB_TOKEN"; };f'
    fi
    if [[ "$BRANCH" ]]; then
        echo "Checking out branch: ${BRANCH}"
        git checkout "$BRANCH"
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

getGithubReleaseNotesForTag() {
    local REPO_NAME=$1
    local TAG=$2

    if [[ -z $GITHUB_TOKEN ]]; then
        echo "Error: GITHUB_TOKEN environment variable is not set."
        return 1
    fi

    if [[ -z $GITHUB_ORG ]]; then
        echo "Error: GITHUB_ORG environment variable is not set."
        return 1
    fi

    local API_URL="https://api.github.com/repos/${GITHUB_ORG}/${REPO_NAME}/releases/tags/${TAG}"

    local RESPONSE=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github.v3+json" \
        "${API_URL}")

    local RELEASE_NOTES="$(echo "$RESPONSE" | jq -r '.body // empty' | sed 's/## /### /g')"

    if [[ -z "$RELEASE_NOTES" ]]; then
        echo "Error: Could not fetch release notes for ${REPO_NAME} tag ${TAG}"
        return 1
    fi

    echo "$RELEASE_NOTES"
}

generateReleaseNotesText() {
    local CURRENT_TAG=$1
    local PREV_TAG=$(git describe --abbrev=0 --tags `git rev-list --tags --skip=1 --max-count=1` || echo "")

    if [[ -z $PREV_TAG ]]; then
        COMMITS="$(git log --pretty='%s')"
    else
        if [[ "$CURRENT_TAG" != *.0 ]]; then
            PREV_TAG="v$(decrementVersionNumber ${CURRENT_TAG#v})"
        fi
        COMMITS="$(git log --pretty='%s' ${PREV_TAG}..${CURRENT_TAG})"
    fi

    local RELEASE_NOTES=""
    local -A REPO_VERSIONS  # Associative array to store versions per repo
    local -a REPO_ORDER     # Array to maintain repo order
    local FEATURES=""
    local FIXES=""
    local PATCHES=""

    # First pass: collect all dependency updates and conventional commits
    while IFS= read -r line; do
        if [[ "$line" == "ci: Updated dependency - "* ]]; then
            # Extract repo name and version from "ci: Updated dependency - repo_name=version"
            local dep_part="${line#ci: Updated dependency - }"
            local repo_name="${dep_part%%=*}"
            local version="${dep_part#*=}"

            # Track repo order (only add if not already tracked)
            if [[ -z "${REPO_VERSIONS[$repo_name]}" ]]; then
                REPO_ORDER+=("$repo_name")
            fi

            # Append version to repo's version list (pipe-separated)
            if [[ -n "${REPO_VERSIONS[$repo_name]}" ]]; then
                REPO_VERSIONS[$repo_name]="${REPO_VERSIONS[$repo_name]}|${version}"
            else
                REPO_VERSIONS[$repo_name]="${version}"
            fi
        elif [[ "$line" == "feat:"* || "$line" == "feat("* ]]; then
            local msg="${line#feat:}"
            msg="${msg#feat(*)}"
            msg="${msg# }"
            FEATURES="${FEATURES}- ${msg}\n"
        elif [[ "$line" == "fix:"* || "$line" == "fix("* ]]; then
            local msg="${line#fix:}"
            msg="${msg#fix(*)}"
            msg="${msg# }"
            FIXES="${FIXES}- ${msg}\n"
        elif [[ "$line" == "patch:"* || "$line" == "patch("* ]]; then
            local msg="${line#patch:}"
            msg="${msg#patch(*)}"
            msg="${msg# }"
            PATCHES="${PATCHES}- ${msg}\n"
        fi
    done <<< "$COMMITS"

    # Add conventional commits sections
    if [[ -n "$FEATURES" ]]; then
        RELEASE_NOTES="${RELEASE_NOTES}### Features\n\n${FEATURES}\n"
    fi

    if [[ -n "$FIXES" ]]; then
        RELEASE_NOTES="${RELEASE_NOTES}### Fixes\n\n${FIXES}\n"
    fi

    if [[ -n "$PATCHES" ]]; then
        RELEASE_NOTES="${RELEASE_NOTES}### Patches\n\n${PATCHES}\n"
    fi

    # Build release notes for dependencies
    for repo_name in "${REPO_ORDER[@]}"; do
        RELEASE_NOTES="${RELEASE_NOTES}## ${repo_name}\n\n"

        # Split versions and process each
        IFS='|' read -ra versions <<< "${REPO_VERSIONS[$repo_name]}"
        for version in "${versions[@]}"; do
            RELEASE_NOTES="${RELEASE_NOTES}### ${version}\n\n"

            # Fetch GitHub release notes for this repo/version
            local github_notes=$(getGithubReleaseNotesForTag "$repo_name" "$version" 2>/dev/null)
            if [[ -n "$github_notes" && "$github_notes" != "Error:"* ]]; then
                RELEASE_NOTES="${RELEASE_NOTES}${github_notes}\n\n"
            fi
        done
    done

    echo -e "$RELEASE_NOTES"
}
