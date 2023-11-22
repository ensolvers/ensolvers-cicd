# Scripts

This folder of the repo contains a set of scripts that simplify common tasks and automate work

## [db-dump](./db-dump/)

TBD

## Git

A set of scripts meant to help with common tasks in git

### [install-git-hooks.sh](./git/install-git-hooks.sh) 

Ensures that scripted tasks that run on git hooks (e.g. autoformatting) are configured properly. It is recommended that this script runs tied to other event that ensures that is run within common tasks - so hooks are "silently" installed. This script assumes that backend and frontend are found in `modules/backend` and `modules/frontend`