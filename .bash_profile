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
    if [ -d .git ]; then
        echo "$BOLD$YELLOW[$RED$(localbranch) $YELLOW: $RED$(remotebranch)$YELLOW]$RESET "
    fi
}

export PS1='\[$BOLD$MAGENTA\]\u\[$RESET\]@\[$BLUE\]\h \[$GREEN\]\w \[$(gitinfo)$RESET\]\[$CYAN\]$\[$RESET\] '
