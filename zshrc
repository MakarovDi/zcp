#####################################################################
##         ZSH Config Pack by Dmitry Makarov (aka Loki)            ##
##                       Version 0.4                               ##
#####################################################################
## Config is separated in 5 parts:                                 ##
##   1. completions  - configure autocompletion features           ##
##   2. keyboard     - provide key bindings                        ##
##   3. helpers      - contains functions with some informations   ##
##   4. aliases      - some aliases                                ##
##   5. subroutines  - some special programs                       ## 
#####################################################################
##             Absolutly free to use/modification                  ##
#####################################################################
## History ('*' = fix, '+' = new feature, '-' = deprecated)        ##
##-----------------------------------------------------------------##
## Version 0.1 - [09.03.2014]                                      ##
##   + first version                                               ##
## Version 0.2 - [15.03.2014]                                      ##
##   *[keyboard] additional key-codes for windows/putty support    ##
##   +[subroutines]                                                ##
##   +[aliases]                                                    ## 
##   +[completion] command not found handles with pkgfile          ##
##   + allow tab-completion for aliases                            ##  
##                                                                 ##
## Version 0.3 - [22.03.2014]                                      ##
##   + use 256 color in user terminal                              ##
##   + use locale                                                  ##
##   +[aliases] screen support                                     ##
##   +[aliases] mc support                                         ##
##   * fixed aliases tab-comletion                                 ##
##   - separated history                                           ##
##                                                                 ##
## Version 0.4 - [23.03.2014]                                      ##
##   + installation system                                         ##
##   *[keyboard] fixed mc Ctrl+O                                   ##
##                                                                 ##
## Version 0.5 - [--.--.2014]                                      ## 
##   +[aliases] mdadm support                                      ##
##   +[aliases] function for reload config (zcp-reload)            ##
##   +[install] autoreload config (use . ./install)                ##
##
#####################################################################

ZSH_CONFIG_PACK_DIR=/etc/zsh/

#####################################################################
## Options                                                         ##
#####################################################################

# append history list to the history file; this is the default but we make sure
# because it's required for share_history.
setopt append_history

# import new commands from the history file also in other zsh-session
setopt share_history

# save each command's beginning timestamp and the duration to the history file
setopt extended_history

# If a new command line being added to the history list duplicates an older
# one, the older command is removed from the list
setopt histignorealldups

# remove command lines from the history list when the first character on the
# line is a space
setopt histignorespace

# if a command is issued that can't be executed as a normal command, and the
# command is the name of a directory, perform the cd command to that directory.
setopt auto_cd

# in order to use #, ~ and ^ for filename generation grep word
# *~(*.gz|*.bz|*.bz2|*.zip|*.Z) -> searches for word not in compressed files
# don't forget to quote '^', '~' and '#'!
setopt extended_glob

# display PID when suspending processes as well
setopt longlistjobs

# try to avoid the 'zsh: no matches found...'
setopt nonomatch

# report the status of backgrounds jobs immediately
setopt notify

# whenever a command completion is attempted, make sure the entire command path
# is hashed first.
setopt hash_list_all

# not just at the end
setopt completeinword

# Don't send SIGHUP to background processes when the shell exits.
setopt nohup

# make cd push the old directory onto the directory stack.
# setopt auto_pushd

# don't push the same dir twice.
#setopt pushd_ignore_dups

# avoid "beep"ing
setopt nobeep

# * shouldn't match dotfiles. ever.
setopt noglobdots

# use zsh style word splitting
setopt noshwordsplit

# don't error out when unset parameters are used
setopt unset

# enable zsh-globbing
setopt extended_glob

# allow correct tab-completion for aliases (like for a command inside an aliase)
unsetopt complete_aliases


#####################################################################
## Exports                                                         ## 
#####################################################################

# set nano as default editor
export EDITOR=`which nano`

# set less as default pager
export PAGER=${PAGER:-less}

# if we don't set $SHELL then aterm, rxvt,.. will use /bin/sh or /bin/bash :-/
export SHELL='/bin/zsh'

# set terminal property (used e.g. by msgid-chooser)
export COLORTERM="yes"

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath

if [[ -e /etc/locale.conf ]]; then
   source /etc/locale.conf
   export LANG
   export LC_ALL=$LANG
   export LC_MESSAGES=$LANG
fi


#####################################################################
## ZSH modules                                                     ## 
#####################################################################

typeset -A mods # define array

# which ones will load (see [man zshmodules])
mods=(
  parameter  ## access to internal hash tables
  complist   ## privede completion via list/menu, gives keyboad widgets (like forward-word,...)
  mathfunc   ## Standard scientific functions for use in [eval]
  net/socket ## manipulation with sockets
  terminfo   ## terminfo database
  zle        ## zsh line editor (gives bindkey, ... )
)

# load modules
for mod in ${mods}; do
    zmodload -i zsh/${mod} 2>/dev/null || print "Notice: no ${mod} available :("
done

# autoload zsh modules when they are referenced
zmodload -a  zsh/stat    zstat
zmodload -a  zsh/zpty    zpty
zmodload -ap zsh/mapfile mapfile


#####################################################################
## ZSH variables                                                   ##
#####################################################################

# report about cpu-/system-/user-time of command if running longer than
# 5 seconds (zsh feature)
REPORTTIME=5

# watch for everyone but me and root
watch=(notme root)

ZSHDIR=${ZDOTDIR:-${HOME}/.zsh}
[[ -e ${ZSHDIR} ]] || mkdir ${ZSHDIR}

# history settings
HISTFILE=${ZSHDIR}/.zsh_history
HISTSIZE=5000
SAVEHIST=10000 # useful for setopt append_history

# completion dump file
ZSH_COMPDUMP=${ZSHDIR}/.zcompdump


#####################################################################
## Colorize programs                                               ##
#####################################################################

if [[ $EUID != 0 ]]; then
  case "$TERM" in
    'xterm')  export TERM=xterm-256color;;
    'screen') export TERM=screen-256color;;
    'Eterm')  export TERM=Eterm-256color;;
  esac
fi

# load colors for different file types 
eval $(dircolors -b)

alias ls='ls --color=auto'

alias grep='grep --color=auto'

# set colors in less (check it in [man] command)
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'


#####################################################################
## Keyboard                                                        ##
#####################################################################

# load keyboard config
# for information press [Ctrl+k]
source ${ZSH_CONFIG_PACK_DIR}/keyboard

#####################################################################
## Completion system                                               ##
#####################################################################

# load completion config
source ${ZSH_CONFIG_PACK_DIR}/completions

#####################################################################
## Prompt                                                          ##
#####################################################################

# load prompt settings
source ${ZSH_CONFIG_PACK_DIR}/prompt

#####################################################################
## Aliases                                                         ##
#####################################################################

# load aliases
source ${ZSH_CONFIG_PACK_DIR}/aliases

