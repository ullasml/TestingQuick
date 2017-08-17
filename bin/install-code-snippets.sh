#!/usr/bin/env bash

PROJECT_DIR=$(dirname $0)/..
CODE_SNIPPET_DIR=~/Library/Developer/Xcode/UserData/CodeSnippets
cp "$PROJECT_DIR"/CodeSnippets/* "$CODE_SNIPPET_DIR"
echo Installed code snippets to "$CODE_SNIPPET_DIR"
