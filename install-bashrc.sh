#!/usr/bin/env bash

echo Copying to ~/.bashrc
cp --backup=t .bashrc ~/.bashrc
echo Copying to ~/.bashrc.local.example
cp --backup=t .bashrc.local.example ~/.bashrc.local.example
echo Copying to ~/.bash_profile
cp --backup=t .bash_profile ~/.bash_profile

echo Done. 
