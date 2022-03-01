#!/bin/bash

# Get the absolute path of the script
# SCRIPT_FOLDER="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
SCRIPT_FOLDER=$(
cd $(dirname $0)
pwd
)

CC_ROOT_PATH=$SRCROOT/CodeCoverage
CC_RESOURCES_PATH=$CC_ROOT_PATH/resources
CC_GIT_DIFF_PATH=$CC_ROOT_PATH/git_diff
CC_RESULT_PATH1=$CC_ROOT_PATH/lcov_html
CC_RESULT_PATH2=$CC_ROOT_PATH/llvm_cov_html

function cc_echo {
    echo "Code Coverage Log ==> $1"
}

function create_files {
    if [[ -d $CC_ROOT_PATH ]]; then
    cc_echo "$CC_ROOT_PATH exist."
    else
    mkdir $CC_ROOT_PATH
    fi
    
    if [[ -d $CC_RESOURCES_PATH ]]; then
    cc_echo "$CC_RESOURCES_PATH exist."
    else
    mkdir $CC_RESOURCES_PATH
    fi
    
    if [[ -d $CC_GIT_DIFF_PATH ]]; then
    cc_echo "$CC_GIT_DIFF_PATH exist."
    else
    mkdir $CC_GIT_DIFF_PATH
    fi
    
    if [[ -d $CC_RESULT_PATH1 ]]; then
    cc_echo "$CC_RESULT_PATH1 exist."
    else
    mkdir $CC_RESULT_PATH1
    fi
    
    if [[ -d $CC_RESULT_PATH2 ]]; then
    cc_echo "$CC_RESULT_PATH2 exist."
    else
    mkdir $CC_RESULT_PATH2
    fi
}

function copy_macho_and_scripts {
    cc_echo "Mach-O path: $CODESIGNING_FOLDER_PATH"
    cp -r $CODESIGNING_FOLDER_PATH $CC_RESOURCES_PATH
}

function main {
    create_files
    copy_macho_and_scripts
}

main
