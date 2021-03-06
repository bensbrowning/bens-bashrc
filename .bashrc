######################################################################
# COMMENTS & DOCUMENTATION {{{1
######################################################################
# NOTE!!!! Don't make changes to this file for a single machine. Use
# .bashrc.local. See "Local Customisations" below.
######################################################################
# General {{{2
######################################################################
# This file is designed on the assumption that bash is NOT our login
# shell. If it was then the env variable setting should be in the
# .bash_profile file, not the .bashrc. I've made a special effort to keep
# the number of external calls to a minimum, since it was getting to the
# point that it would take 5 seconds to fire up bash on an Sun Ultra 10!
# As a result, there are some unusual constructs in here. There are still
# some external calls left (e.g. calls to sed) but they are not in loops
# and I doubt they make that much difference to performance.
#
######################################################################
# Local Customisations {{{2
######################################################################
# It's best not to change this file on a machine-by-machine basis. For
# local extensions this file calls ~/.bashrc.local if it exists. It's
# called twice...  once before all processing with a single parameter ($1)
# "pre" and once after all processing with a single parameter "post".
#
# In addition, a number of variables are set and are available for use by
# the ~/.bashrc.local script. These variables are UNset before this file
# exits, so they are not available once the shell is interactive.
#
# The variables set by this script are:
#   _debugging                          Manually set (see below) to "1" if
#                                       parts of this and called scripts
#                                       should be verbose in their output.
#                                       Unset otherwise. NOTE that some
#                                       non-interactive tools (e.g. rsync)
#                                       get confused by stuff being
#                                       printed at shell startup so
#                                       normally this should be OFF.
#
#   _shell_is_interactive               Set to "1" if this is an interactive
#                                       session, and unset otherwise. No
#                                       output should be produced if this
#                                       is set.
#
#   _running_X                          Set to "1" if we are running under
#                                       X and appropriate stuff should be
#                                       done.  NOTE that when the "pre"
#                                       call to ~/.bashrc.local is made,
#                                       _running_X is based on a VERY
#                                       simple test (is DISPLAY set?).  By
#                                       the time the "post" call is made
#                                       _running_X reflects more thorough
#                                       probes for a usable X server. It's
#                                       best to wait for the "post" call
#                                       before using X since timeouts on
#                                       non-existant servers may cause
#                                       this script to appear to hang
#
######################################################################
# TODO: {{{2
######################################################################
#   It seems that I'm constantly adding new features that leap-frog the
#   TODO list below, so this is really a SHOULDDO list, but for what it's
#   worth:
#     - surround the ENV var and other once-only stuff with a big if,
#       testing $0 or something for login-shellness then call this file
#       from /.bash_profile with something like:
#       [ -f ~/.bashrc ] && . /.bashrc
#     - Policy question: Should stuff in the /usr/local tree be used in
#       preference to stuff in system directories like /usr/bin? At the
#       moment the path has the /usr/local stuff later. That means that a
#       newer version of software installed there won't get used.
#
######################################################################
# Folding {{{2
######################################################################
# The funny comments in this file, made from braces, like the ones before
# this paragraph, are for vim's folding mode. They make navigation in the
# file a lot easier  Unfortunately they require vim version >= 6.0. See
# ":help folding" in vim for more info. They should't affect any other
# editor, just think of them as marking the start and end of sections.
######################################################################

######################################################################
# Set up some variables for later {{{1
######################################################################
# NOTE: If a variable is added here it should be unset at the end of the
# file!

# _debugging=1

# $- contains the options provided to the shell
[[ $- == *i* ]] && _shell_is_interactive=1
[[ -n "$DISPLAY" ]] && _running_X=1

######################################################################
# Run PRE-run scripts
######################################################################
  
for i in `ls $HOME/.bashrc.includes/PRE-*.sh`
do
  [[ $_debugging ]] && echo Sourcing $i
  . $i
done
#echo Done sourcing

######################################################################
# Make the first call on the local settings file {{{1
######################################################################

[ -f $HOME/.bashrc.local ] && . $HOME/.bashrc.local pre

######################################################################
# PATH, MANPATH, LD_LIBRARY_PATH {{{1
######################################################################
# Comments {{{2
# We do this first since we might need them later. 
#
# LOCALPROGS allows programs to be installed in
# /usr/local/<progname>/{bin,man,sbin,lib} and still be found.  OPTPROGS
# does the same thing for /opt/<progname> - mostly for Solaris. MYOPTPROGS
# is the same thing for ~/opt, but I don't understamd why you'd install
# stuff in your own home dir and then not want to run it!
#
# Here we add EVERY path we're likely to need, independant of OS. We will
# strip the ones that don't exist later
# 
# Variable setup {{{2
# I don't normally set these to a complete list since not all users need
# all apps, but if either of the {LOCAL,OPT}PROGS variables is not set it
# will be automatically filled below with all values from the disk.

#LOCALPROGS="vim screen teTeX"
#OPTPROGS="SUNWcluster SUNWmd"
#MYOPTPROGS=""

# Basic Entries
PATH=/sbin:/usr/sbin:/usr/bin:/usr/dt/bin:$PATH
# Solaris entries
PATH=$PATH:/usr/ccs/bin:/usr/openwin/bin:/usr/sfw/bin:/usr/perl5/bin
# SunCluster entries (inc DTK)
PATH=$PATH:/usr/cluster/bin:/usr/cluster/lib/sc:/usr/cluster/dtk/bin
# SunFire 15k path
PATH=$PATH:/opt/SUNWSMS/bin
# Tru64 entries
PATH=$PATH:/usr/bin/X11:/usr/tcb/bin
# MacOSX entries
PATH=/sw/bin:/sw/sbin:/Developer/Tools:$PATH
# My entries
PATH=$PATH:/usr/local/bin
# Late Solaris entries - definitely want these at the end
PATH=$PATH:/usr/ucb

MANPATH=/sw/share/man:/usr/share/man:/usr/dt/share/man
MANPATH=$MANPATH:/usr/local/man:/usr/openwin/man
MANPATH=$MANPATH:/usr/X11R6/man/:/usr/perl5/man
MANPATH=$MANPATH:/opt/SUNWSMS/man
MANPATH=$MANPATH:/usr/cluster/man:/usr/cluster/dtk/man:/usr/sfw/man
LD_LIBRARY_PATH=/usr/local/lib

# Auto-add paths {{{2
# /usr/local {{{3
if [ -d /usr/local ]; then
    for PROG in ${LOCALPROGS:-$(cd /usr/local; echo *)}
    do
        if [ -d /usr/local/$PROG/bin ]; then
            PATH=/usr/local/$PROG/bin:$PATH
        fi
        if [ -d /usr/local/$PROG/sbin ]; then
            PATH=/usr/local/$PROG/sbin:$PATH
        fi
        if [ -d /usr/local/$PROG/man ]; then
            MANPATH=/usr/local/$PROG/man:$MANPATH
        fi
        if [ -d /usr/local/$PROG/lib ]; then
            LD_LIBRARY_PATH=/usr/local/$PROG/lib:$LD_LIBRARY_PATH
        fi
    done
fi

# /opt {{{3
if [ -d /opt ]; then
    for PROG in ${OPTPROGS:-$(cd /opt; ls)}
    do
        if [ -d /opt/$PROG/bin ]; then
            PATH=$PATH:/opt/$PROG/bin
        fi
        if [ -d /opt/$PROG/sbin ]; then
            PATH=$PATH:/opt/$PROG/sbin
        fi
        if [ -d /opt/$PROG/man ]; then
            MANPATH=$MANPATH:/opt/$PROG/man
        fi
        if [ -d /opt/$PROG/lib ]; then
            LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/$PROG/lib
        fi
    done
fi

# $HOME/opt {{{3
# Don't do this if our home directory is /. This won't affect the
# resulting PATH but it will make the loop below faster
if [ -d $HOME/opt -a $HOME != "/" ]; then
    for PROG in ${MYOPTPROGS:-$(cd $HOME/opt; echo *)}
    do
        if [ -d $HOME/opt/$PROG/bin ]; then
            PATH=$HOME/opt/$PROG/bin:$PATH
        fi
        if [ -d $HOME/opt/$PROG/sbin ]; then
            PATH=$HOME/opt/$PROG/sbin:$PATH
        fi
        if [ -d $HOME/opt/$PROG/man ]; then
            MANPATH=$HOME/opt/$PROG/man:$MANPATH
        fi
        if [ -d $HOME/opt/$PROG/lib ]; then
            LD_LIBRARY_PATH=$HOME/opt/$PROG/lib:$LD_LIBRARY_PATH
        fi
    done
fi

unset PROG OPTPROGS LOCALPROGS

# Clean up path-like variables {{{2
# Here we clean up the PATH and similar variables by removing non-existant
# dirs and duplicates.
#
# This whole thing is complicated by the fact that we want to keep the
# existing path components in order, so we can't just use sort -u
#
# We do this by declaring a function that cleans a variable. This function
# is currently left declared for future use. TODO: Should we unset this?

# pathclean: Clean up path-like variables {{{3
# arguments: name-of-var-to-clean
# 
# Note that this function's parameter is the NAME of the variable to clean
# up, not the contents of the variable. The variable is changed in-place.
# This is the bash equivalent to pass-by-reference!

function pathclean() {
    # Variable Declarations 
    local -a newpathcomps     # Array of new path components
    local -i alreadyseen      # Have we already seen this component?
    local component           # Current component we're looking at
    local -i i                # loop var
    local thevar=$1           # The NAME of the variable we're cleaning

    # Clean up the PATH 
    # Expunge double /s and make : into a space. Unfortunatly, this breaks
    # on path entries with a space in them, as happens in the cygwin
    # environment with the fabulous "Program Files" directory, so we have
    # to kludge them into | and then back again... 
    for component in $(echo ${!thevar} |
                        sed -e 's/ /|/g' -e 's/:/ /g' -e 's#//#/#g')
    do
        if [[ -d ${component//|/ } ]]; then
            # The directory exists, lets check we haven't already seen it
            alreadyseen=0
            i=0
            while (( $i < ${#newpathcomps[*]} )); do
                if [[ ${newpathcomps[i]} == $component ]]; then
                    alreadyseen=1
                    break
                fi
                (( i = i + 1 ))
            done
            if (( ! alreadyseen )); then
                newpathcomps[i]=$component
            fi
        fi
    done
    # I'm just not game to wrap this line!
    eval "$thevar=\"$( echo ${newpathcomps[*]} | sed -e's/ /:/g' -e 's/|/ /g')\""
}

# Perform the cleaning {{{3

pathclean PATH
pathclean MANPATH
pathclean LD_LIBRARY_PATH

export PATH MANPATH LD_LIBRARY_PATH

######################################################################
# Terminal setup {{{1
######################################################################
# Set up the terminal (based on the TERM variable). Doesn't work properly
# on solaris (esp. in CDE) 'cos tset is Bezerkeley :-(
# TODO: I think there's a tset in /usr/ucb
if [[ "$_shell_is_interactive" == 1 && $OSTYPE != solaris* ]]; then 
    if [[ $(type -p tset) ]]; then
        eval $(SHELL=/bin/sh tset -r -s)
    fi
fi
        
######################################################################
# Shell options {{{1
######################################################################
# Set my preferred options
shopt -s cdspell checkwinsize histreedit

# If I hit <tab> on a blank line, I DON'T want to see a list of all the
# comands in my PATH - who would EVER want that??  This option appeared in
# bash 2.04, so it's not in the Solaris 8 version of bash.  Rather than
# checking for the version, check for the existance of the option:
[[ $(shopt) == *no_empty_cmd_completion* ]] &&
    shopt -s no_empty_cmd_completion

#Only put duplicate lines in the history once
HISTCONTROL=ignoredups

######################################################################
# Prompt and other terminal settings {{{1
######################################################################
# Set the prompt {{{2
# If it's an xterm then set the window title to reflect $PWD 
# If we're root, make the prompt red
# TODO: Should use tput for a lot of this stuff
# Declare some variables to work with
declare basicprompt='\h:\W\$'
# We need extglob turned on, so save the current value
declare oldextglob=$( shopt extglob )
shopt -s extglob
declare settitle setcoloron setcoloroff
# set up complicated prompt stuff based on terminal type
case $TERM in
    dtterm*|*xterm*|screen*|linux)
        # These use the basic ANSI color sequences.
        setcoloroff="\[\033[0m\]"
        if (( ! $UID )); then
            # we are root... make the prompt red
            setcoloron="\[\033[0;31m\]"
        else
            # non-root, but I still like color
            setcoloron="\[\033[1;32m\]"
        fi
        if [[ $TERM == +(*xterm*|dtterm*|screen*) ]]; then
            # These terminals have a title that can be set.
            # This magic came from one of the linux HOWTOs
            #PS1='\[\033]0;\h: \w\007\]\h:\W\$ '
            case $TERM in
                *xterm*|dtterm*)
                    settitle="\[\033]0;\h: \w\007\]"
                    ;;
                screen*)
                    # for screen I want to set the window title to only
                    # the hostname, and use the hardstatus for the path.
                    # The escape sequences to set the hardstatus are the
                    # same as those to set the title in xterm.
                    settitle='\[\033k\h\033\\\033]0;\w\007\]'
                    ;;
            esac
        fi
        ;;
    *)
        # Nothing special here
        ;;
esac
PS1="\u@${settitle}${setcoloron}${basicprompt}${setcoloroff} "

# Remove any exporting of PS1 since it looks hideous in other shells and 
# bash will just re-read this file anyway
export -n PS1

# set extglob back to how we found it
[[ $oldextglob == *off ]] && shopt -u extglob
unset basicprompt settitle setcoloron setcoloroff oldextglob

######################################################################
# Aliases {{{1
######################################################################
# Less is MORE {{{2
unalias less 2>/dev/null
if [[ $(type -p less) ]]; then
    # without less, man is CRAPPO (esp. on Solaris!).
    export PAGER="less -si"
else
    # We don't have less, but my fingers are ALWAYS typing it anyway. So
    # this prevents (even more) insanity.
    alias less=more
fi

# vi is good, but vim is better.  and I like nano -ben {{{2
# I'm in the habit of typing 'vi' but if vim is there, I'd prefer that


if [[ $(type -p nano) ]]; then
        alias nano="$(type -p nano) -w"
		export EDITOR=nano
		export VISUAL=nano
elif [[ $(type -p vim) ]]; then
    if [[ $OSTYPE == solaris* && $TERM == xterm ]]; then 
        # I'm probably using putty on a PC so to get colors going:
        alias vi='TERM=xtermc vim'
    else
        alias vi=vim
    fi
    export EDITOR=$(type -p vim)
    export VISUAL=$(type -p vim)
else
    export EDITOR=$(type -p vi)
    export VISUAL=$(type -p vi)
fi

######################################################################
# Functions {{{1
######################################################################
# ruler {{{2
# This one is sometimes handy. Once I'd written it, I realised I could
# have just used a static set of strings and extracted the needed
# substring, but this is niftier and more educational (for me) and a
# little more robust. By the way, the argument was really just meant so
# you could have a 0-based ruler, as well as a 1-based one. If you ask for
# one that will reach over 1000 or less than 0 it will look crappy, but
# you deserve what you get, IMHO!

# Unfortunately the for (( ... )) feature that I use here did not appear
# till bash 2.04, so it's not there on Solaris 8 and I have to put the
# function definition INSIDE an if statement. Ugh!. Worse, there's no easy
# way to test for its availability (a la no_empty_cmd_completion, above).
# As a result, I have to check for the bash version. Uerrgh! But wait.
# there's more!  There's no string >= operator, so this is particularly
# unpleasant - just look away if you are eating.
# Finally, of course the shell still processes  the contents of an if
# branch that it's not executing, so we have to put the entire function
# definition in a big string so we can eval it. I don't know why I bother!

if [[ ( ${BASH_VERSINFO[0]} = "2"  || ${BASH_VERSINFO[0]} > "2" )
   && ( ${BASH_VERSINFO[1]} = "04" || ${BASH_VERSINFO[1]} > "04" ) ]]; then
   eval ' function ruler {
        local start end col firstline secondline lastline
        declare -i start end col
        start="$1"
        [ -z "$1" ] && start=1
        (( end = COLUMNS + start ))
        # loop over the columns
        for (( col=start; col < end; col++ )); do
            # prepare the first line
            if (( col % 10 == 0 && col / 100 != 0 )); then
                firstline="$firstline"$(( col / 100 ))
            else
                firstline="$firstline-"
            fi
            # prepare the second line
            if (( col % 10 == 0 )); then
                secondline="${secondline}"$(( col / 10 % 10 ))
            else
                secondline="$secondline "
            fi
            # prepare the last line
            lastline="$lastline"$(( col % 10 ))
        done
        if (( start < 85 )); then
            printf "%4d %-10s%s" $COLUMNS "columns" "${firstline:15}"
        else
            echo "$firstline"
        fi
        echo "$secondline"
        echo "$lastline"
    }
    ' # end the eval
fi # End bash version test

# This function lets me use either the System V (-ef) or BSD (aux) style
# switches on Solaris. It just runs the appropriate ps based on whether
# there's a - there or not.
# Been meaning to do this for a while, then came across one at
# http://www.beaglebros.com/unix - so I stole it. I've since changed it,
# but when do I stop crediting the inspiration?
if [[ $OSTYPE == solaris* ]]; then 
    function ps {
        if [ -n "$1" ]; then
            if [[ $1 == -* ]]; then
                /usr/bin/ps $@
            else
                /usr/ucb/ps $@
            fi
        else
            /usr/bin/ps $@
        fi
    }

fi # end solaris function


######################################################################
# Make the last call on the local settings file {{{1
######################################################################

[ -e $HOME/.bashrc.local ] && . $HOME/.bashrc.local post

######################################################################
# Run POST-run scripts
######################################################################
  
for i in `ls $HOME/.bashrc.includes/POST-*.sh`
do
  [[ $_debugging ]] && echo Sourcing $i
  . $i
done
#echo Done sourcing

######################################################################
# Clean up {{{1
######################################################################
unset _shell_is_interactive
unset _running_X
unset _debugging

