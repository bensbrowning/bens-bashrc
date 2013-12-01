#!/bin/bash

# Found at http://usalug.com/phpBB3/viewtopic.php?t=10456

#Translate a Word  - USAGE: translate house spanish  # See dictionary.com for available languages (there are many).
translate ()
{
TRANSLATED=`lynx -dump "http://dictionary.reference.com/browse/${1}" | grep -i -m 1 -w "${2}:" | sed 's/^[ \t]*//;s/[ \t]*$//'`
if [[ ${#TRANSLATED} != 0 ]] ;then
   echo "\"${1}\" in ${TRANSLATED}"
   else
   echo "Sorry, I can not translate \"${1}\" to ${2}"
fi
}
