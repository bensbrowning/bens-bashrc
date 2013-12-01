#!/usr/bin/env bash

echo Tarring previous bashrc stuff
tar zcf ~/.backup.bash-star.`date +%Y-%m-%d-%H%M`.tgz ~/.bash*

echo Copying to ~/.bashrc
cp -a .bashrc .bashrc.*.example .bash_profile .bashrc.includes ~/

echo Done. 
