#!/bin/sh

echo "Wellcome here! It's my collection of helpfull scripts which You can use" >> README.md
git init
git add .
git commit -m "Hello World!))"
git remote add origin git@github.com:vitoris/helpfull-scripts.git
git push -u origin master
