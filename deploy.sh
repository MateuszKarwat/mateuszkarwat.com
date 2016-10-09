#!/bin/bash

branch_name="$(git rev-parse --abbrev-ref HEAD)"

if [ $branch_name != "master" ];
then 
  echo "Not on master"
  exit -1
fi

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo -d docs

# Add changes to git.
git add -A

# Commit changes.
msg="Rebuilding site `date`"
if [ $# -eq 1 ]
    then msg="$1"
fi

git commit -m "$msg"

# Push source and build repositories.
git push origin master
git subtree push --prefix public origin gh-pages
