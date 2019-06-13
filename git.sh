#!/bin/bash

# Manage git easily

set -e

sd=$(cd "$(dirname "$0")"; pwd)

branch="master"

getArgument(){
    if [ "${1}" == "" ] || [ "${1}" == "help" ] || [ "${1}" == "-h" ]; then
        echo "Usage: bash $0 COMMAND"
        echo "e.g. bash $0 prune ==> Prune any branches from your local that have been merged or deleted in remote"
        echo "e.g. bash $0 create DEVOPS-1 ==> Create a new git branch, checks it out, and publishes the branch"
        echo "e.g. bash $0 rename DEVOPS-2 ==> Renames current branch to first argument"
        exit 1
    elif [ "${1}" == "prune" ]; then
        prune "$2"
    elif [ "${1}" == "create" ]; then
        jiraCheck "$1" "$2" && changeOwn && create "$2"
    elif [ "${1}" == "rename" ]; then
        jiraCheck "$1" "$2" && changeOwn && rename "$2"
    else
        echo "Invalid argument: ${1}"
    fi
}

jiraCheck(){
    if [[ "${2}" == DEVOPS-* ]] || [[ "${2}" == CLOUD-* ]] || [[ "${2}" == MOBILE-* ]]; then
        echo ""
    else
        echo "Invalid project: ${2}"
        exit 1
    fi
}

changeOwn(){
    sudo chown -R "${USER}":"${USER}" "${sd}"/*
}

create(){
    git checkout ${branch}
    git pull
    git checkout -b "$1"
    git push --set-upstream origin "$1"
}

rename(){
    currentBranch=$(git rev-parse --abbrev-ref HEAD)
    git branch -m "$currentBranch" "$1"   
    git push origin :"$currentBranch"
    git push --set-upstream origin "$1"
    git checkout "$1"
}

prune(){
    git branch --merged | grep -v "*" | grep -v "${branch}" | xargs git branch -d
}

getArgument "$1" "$2"
