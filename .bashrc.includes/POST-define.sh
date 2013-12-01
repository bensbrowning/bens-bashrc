#!/bin/bash

# Found at http://usalug.com/phpBB3/viewtopic.php?t=10456
# Define a word - USAGE: define dog
define ()
{
lynx -dump "http://www.google.com/search?hl=en&q=define%3A+${1}&btnG=Google+Search" | grep -m 3 -w "*"  | sed 's/;/ -/g' | cut -d- -f1 > /tmp/templookup.txt
         if [[ -s  /tmp/templookup.txt ]] ;then   
            until ! read response
               do
               echo "${response}"
               done < /tmp/templookup.txt
            else
               echo "Sorry $USER, I can't find the term \"${1} \""            
         fi   
rm -f /tmp/templookup.txt
}
