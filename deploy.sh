#!/usr/bin/env sh

cur_dateTime="`date +%Y-%m-%d,%H:%m`" 
# 确保脚本抛出遇到的错误
set -e

git add .
git commit -m $cur_dateTime

git push origin master

