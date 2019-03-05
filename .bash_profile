export EDITOR=vim
export GITHUB_USERNAME=MatthewRyanRead

source ~/Developer/mread-util/mread-util.sh

export HISTSIZE=100000
export HISTFILESIZE=1000000
shopt -s histappend

# fancy terminal with git branch info
# format (not including coloring):
# user@computer path/to/current [local-branch-name : remote-branch-name] $

BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
RESET=$(tput sgr0)

gitinfo() {
    local REMOTE_BRANCH=$(remotebranch);
    local LOCAL_BRANCH=$(localbranch);
    local BRANCH_INFO="$RED$LOCAL_BRANCH $YELLOW: $RED$REMOTE_BRANCH"

    if [ -z "$REMOTE_BRANCH" ]; then
        BRANCH_INFO="$RED$(git branch | grep -E '^\*')"
    fi

    if [ -d .git ]; then
        echo "$BOLD$YELLOW[$BRANCH_INFO$YELLOW]$RESET "
    fi
}

export PS1='\[$BOLD$MAGENTA\]\u\[$RESET\]@\[$BLUE\]\h \[$GREEN\]\w \[$(gitinfo)$RESET\]\[$CYAN\]$\[$RESET\] '

alias dev='cd ~/Developer'
