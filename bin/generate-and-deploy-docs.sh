#!/usr/bin/env bash
set -o errexit #abort if any command fails
jazzy -x USE_SWIFT_RESPONSE_FILE=NO # per https://github.com/realm/jazzy/issues/1087
GIT_DEPLOY_DIR=docs GIT_DEPLOY_BRANCH=gh-pages GIT_DEPLOY_REPO=git@github.com:filestack/filestack-swift.git ./bin/deploy-docs.sh
