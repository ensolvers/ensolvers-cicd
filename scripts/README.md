# Scripts

This folder of the repo contains a set of scripts that simplify common tasks and automate work

## [db-dump](./db-dump/)

TBD

## Git

A set of scripts meant to help with common tasks in git

### [install-git-hooks.sh](./git/install-git-hooks.sh) 

Ensures that scripted tasks that run on git hooks (e.g. autoformatting) are configured properly. It is recommended that this script runs tied to other event that ensures that is run within common tasks - so hooks are "silently" installed. This script assumes that backend and frontend are found in `modules/backend` and `modules/frontend`

Installation: 
1. Copy this file in the root of the project
2. Ensure that frontend and backend paths are correct
3. Link this script running into frontend by editing `package.json` and adding then in a `pre` action - for instance, if we want to ensure that it runs every time the user runs the frontend app locally (`yarn start`), we can do the following

```json
...
  },
  "scripts": {
    "start": "vite",
    "prestart": "../../install-git-hooks.sh",
    "build": "tsc && vite build",
    "serve": "vite preview",
...
```